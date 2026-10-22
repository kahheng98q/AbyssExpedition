"""Task-document guards; no Godot or document writes."""
import unittest
import check_003_docs as audit


class TaskAuditTests(unittest.TestCase):
    def setUp(self):
        self.body = (audit.FEATURE / 'tasks.md').read_text(encoding='utf-8-sig')

    def errors(self, body):
        return audit.audit_tasks(body)[1]

    def test_current_convergence_is_valid(self):
        self.assertFalse(self.errors(self.body))

    def test_further_append_is_valid(self):
        self.assertFalse(self.errors(self.body + '\n## Phase 8: Convergence\n\n- [ ] T063 Follow-up per FR-012 (partial)\n'))

    def test_checkbox_changes_are_valid(self):
        changed = self.body.replace('- [X] T001', '- [ ] T001')
        self.assertNotEqual(changed, self.body)
        self.assertFalse(self.errors(changed))

    def test_duplicate_is_rejected(self):
        self.assertTrue(self.errors(self.body + '\n- [ ] T062 Duplicate\n'))

    def test_gap_is_rejected(self):
        self.assertTrue(self.errors(self.body.replace('T062 MEDIUM', 'T064 MEDIUM')))

    def test_malformed_number_is_rejected(self):
        self.assertTrue(self.errors(self.body.replace('T062 MEDIUM', 'T62 MEDIUM')))

    def test_original_description_is_protected(self):
        self.assertTrue(self.errors(self.body.replace('T001 核对', 'T001 忽略')))

    def test_original_deletion_is_rejected(self):
        self.assertTrue(self.errors('\n'.join(line for line in self.body.splitlines() if not line.startswith('- [X] T001 '))))

    def test_original_reorder_is_rejected(self):
        self.assertTrue(self.errors(self.body.replace('T001 核对', 'T002 核对').replace('T002 按', 'T001 按')))

    def test_phase_reorder_is_rejected(self):
        self.assertTrue(self.errors(self.body.replace('## Phase 7:', '## Phase 9:')))


if __name__ == '__main__':
    unittest.main()
