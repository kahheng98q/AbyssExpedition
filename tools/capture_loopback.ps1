[CmdletBinding()]
param([Parameter(Mandatory)][string]$OutputDirectory, [ValidateRange(1,120)][int]$Seconds = 35)
$ErrorActionPreference = 'Stop'
$source = @'
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Diagnostics;
using System.Threading;
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class AudioEnumerator {}
[ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IDevices {
 int EnumAudioEndpoints(int flow, uint mask, out IntPtr devices);
 int GetDefaultAudioEndpoint(int flow, int role, out IDevice device);
}
[ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IDevice {
 int Activate(ref Guid iid, uint context, IntPtr parameters, [MarshalAs(UnmanagedType.IUnknown)] out object value);
 int OpenPropertyStore(uint access, out IntPtr store);
 int GetId([MarshalAs(UnmanagedType.LPWStr)] out string id);
 int GetState(out uint state);
}
[ComImport, Guid("1CB9AD4C-DBFA-4C32-B178-C2F568A703B2"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IClient {
 int Initialize(int shareMode, uint flags, long duration, long period, IntPtr format, ref Guid session);
 int GetBufferSize(out uint frames);
 int GetStreamLatency(out long latency);
 int GetCurrentPadding(out uint padding);
 int IsFormatSupported(int share, IntPtr format, out IntPtr closest);
 int GetMixFormat(out IntPtr format);
 int GetDevicePeriod(out long normal, out long minimum);
 int Start(); int Stop(); int Reset(); int SetEventHandle(IntPtr handle);
 int GetService(ref Guid iid, [MarshalAs(UnmanagedType.IUnknown)] out object value);
}
[ComImport, Guid("C8ADBD64-E71E-48A0-A4DE-185C395CD317"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface ICapture {
 int GetBuffer(out IntPtr data, out uint frames, out uint flags, out ulong devicePosition, out ulong qpcPosition);
 int ReleaseBuffer(uint frames);
 int GetNextPacketSize(out uint frames);
}
[ComImport, Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IVolume {
 int RegisterControlChangeNotify(IntPtr notify); int UnregisterControlChangeNotify(IntPtr notify);
 int GetChannelCount(out uint count);
 int SetMasterVolumeLevel(float db, ref Guid context); int SetMasterVolumeLevelScalar(float level, ref Guid context);
 int GetMasterVolumeLevel(out float db); int GetMasterVolumeLevelScalar(out float level);
 int SetChannelVolumeLevel(uint channel, float level, ref Guid context); int SetChannelVolumeLevelScalar(uint channel, float level, ref Guid context);
 int GetChannelVolumeLevel(uint channel, out float level); int GetChannelVolumeLevelScalar(uint channel, out float level);
 int SetMute([MarshalAs(UnmanagedType.Bool)] bool mute, ref Guid context);
 int GetMute([MarshalAs(UnmanagedType.Bool)] out bool mute);
}
public class CaptureResult {
 public string endpoint_id; public int sample_rate; public int channels; public int bits; public string encoding;
 public double wall_seconds; public long frames; public double peak; public long clipped_samples; public long nonfinite_samples;
 public float? system_volume_scalar; public bool? system_muted; public string capture_started_utc;
 public bool valid; public string limitation = "WASAPI shared render loopback; includes other applications on this endpoint. No normalization or gain applied.";
}
public static class AbyssLoopback {
 static void Check(int result) { Marshal.ThrowExceptionForHR(result); }
 public static CaptureResult Capture(string output, int seconds) {
  IDevices devices = null; IDevice device = null; IClient client = null; ICapture capture = null; IVolume volume = null;
  IntPtr format = IntPtr.Zero; bool started = false;
  var result = new CaptureResult();
  try {
   devices = (IDevices)new AudioEnumerator();
   Check(devices.GetDefaultAudioEndpoint(0, 0, out device));
   Check(device.GetId(out result.endpoint_id));
   Guid clientId = typeof(IClient).GUID; object value;
   Check(device.Activate(ref clientId, 23, IntPtr.Zero, out value)); client = (IClient)value;
   Guid volumeId = typeof(IVolume).GUID;
   try {
    Check(device.Activate(ref volumeId, 23, IntPtr.Zero, out value)); volume=(IVolume)value;
    float level; bool muted; Check(volume.GetMasterVolumeLevelScalar(out level)); Check(volume.GetMute(out muted));
    result.system_volume_scalar=level; result.system_muted=muted;
   } catch { result.system_volume_scalar=null; result.system_muted=null; }
   Check(client.GetMixFormat(out format));
   int tag=(ushort)Marshal.ReadInt16(format,0), channels=(ushort)Marshal.ReadInt16(format,2);
   int rate=Marshal.ReadInt32(format,4), align=(ushort)Marshal.ReadInt16(format,12), bits=(ushort)Marshal.ReadInt16(format,14);
   int extra=(ushort)Marshal.ReadInt16(format,16); int size=18+extra;
   if(size>4096 || channels<1 || channels>16 || align<1) throw new Exception("Unsupported WASAPI mix format.");
   byte[] fmt=new byte[size]; Marshal.Copy(format,fmt,0,size);
   bool floating=tag==3 || (tag==65534 && size>=40 && new Guid(new ReadOnlySpan<byte>(fmt,24,16))==new Guid("00000003-0000-0010-8000-00aa00389b71"));
   bool pcm=tag==1 || (tag==65534 && size>=40 && new Guid(new ReadOnlySpan<byte>(fmt,24,16))==new Guid("00000001-0000-0010-8000-00aa00389b71"));
   if((!floating || bits!=32) && (!pcm || bits!=16)) throw new Exception("Requires native float32 or PCM16; no conversion fallback.");
   Guid session=Guid.Empty;
   Check(client.Initialize(0,0x00020000,10000000,0,format,ref session));
   Guid captureId=typeof(ICapture).GUID;
   Check(client.GetService(ref captureId,out value)); capture=(ICapture)value;
   result.channels=channels; result.bits=bits; result.sample_rate=rate; result.encoding=floating?"IEEE_FLOAT":"PCM";
   using(var pcmData=new MemoryStream()) {
    Check(client.Start()); started=true;
    result.capture_started_utc=DateTime.UtcNow.ToString("O");
    File.WriteAllText(Path.Combine(output,"capture-ready.json"),"{\"capture_started_utc\":\""+result.capture_started_utc+"\"}");
    var watch=Stopwatch.StartNew();
    while(watch.Elapsed.TotalSeconds<seconds) {
     uint packet; Check(capture.GetNextPacketSize(out packet));
     while(packet>0) {
      IntPtr data; uint frames, flags; ulong position,qpc;
      Check(capture.GetBuffer(out data,out frames,out flags,out position,out qpc));
      byte[] buffer=new byte[checked((int)frames*align)];
      if((flags&2)==0) Marshal.Copy(data,buffer,0,buffer.Length);
      pcmData.Write(buffer,0,buffer.Length); result.frames+=frames;
      int stride=bits/8;
      for(int i=0;i<buffer.Length;i+=stride) {
       double sample=floating?BitConverter.ToSingle(buffer,i):BitConverter.ToInt16(buffer,i)/32768.0;
       if(double.IsNaN(sample)||double.IsInfinity(sample)) result.nonfinite_samples++;
       else { result.peak=Math.Max(result.peak,Math.Abs(sample)); if(Math.Abs(sample)>=.99999) result.clipped_samples++; }
      }
      Check(capture.ReleaseBuffer(frames)); Check(capture.GetNextPacketSize(out packet));
     }
     Thread.Sleep(5);
    }
    result.wall_seconds=watch.Elapsed.TotalSeconds;
    Check(client.Stop()); started=false;
    using(var file=new BinaryWriter(File.Create(Path.Combine(output,"loopback-raw.wav")))) {
     file.Write(System.Text.Encoding.ASCII.GetBytes("RIFF")); file.Write((uint)(4+8+fmt.Length+8+pcmData.Length));
     file.Write(System.Text.Encoding.ASCII.GetBytes("WAVEfmt ")); file.Write(fmt.Length); file.Write(fmt);
     file.Write(System.Text.Encoding.ASCII.GetBytes("data")); file.Write((uint)pcmData.Length); file.Write(pcmData.ToArray());
    }
   }
   result.valid=result.frames>0 && result.peak>0 && result.nonfinite_samples==0 && result.system_volume_scalar.HasValue && result.system_muted.HasValue && !result.system_muted.Value && result.system_volume_scalar.Value>0;
   return result;
  } finally {
   if(started && client!=null) client.Stop();
   if(format!=IntPtr.Zero) Marshal.FreeCoTaskMem(format);
   foreach(object item in new object[]{capture,client,volume,device,devices}) if(item!=null) Marshal.ReleaseComObject(item);
  }
 }
}
'@
try {
    Add-Type -TypeDefinition $source
    $result = [AbyssLoopback]::Capture([IO.Path]::GetFullPath($OutputDirectory), $Seconds)
    $result | ConvertTo-Json -Depth 8 | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'loopback.json')
    if (-not $result.valid) { throw 'Loopback capture invalid: silent/muted/unknown volume or incomplete recording.' }
} catch {
    [ordered]@{status='BLOCKED';error=$_.Exception.Message;normalization_applied=$false} | ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $OutputDirectory 'loopback-blocked.json')
    throw
}
