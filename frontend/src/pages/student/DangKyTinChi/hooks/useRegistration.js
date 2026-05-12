import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { message } from 'antd';
import { studentApi } from '../../../../api/endpoints/student';
import { lhpConflicts } from '../utils/conflict';

export function useRegistration(kiHocId) {
  const [available, setAvailable] = useState({ lopHocPhans: [], kiHocTen: '' });
  const [selectedIds, setSelectedIds] = useState(new Set());
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const submittingRef = useRef(false);

  const reload = useCallback(async () => {
    if (!kiHocId) return;
    setLoading(true);
    setError(null);
    try {
      const a = await studentApi.available(kiHocId);
      setAvailable(a);
      setSelectedIds(new Set());
    } catch (e) {
      setError(e?.response?.data?.error?.message || 'Không thể tải danh sách môn học');
    } finally {
      setLoading(false);
    }
  }, [kiHocId]);

  useEffect(() => { reload(); }, [reload]);

  const allChosen = useMemo(() => {
    return (available.lopHocPhans || []).filter(l => l.daDangKy || selectedIds.has(l.id));
  }, [available, selectedIds]);

  const tickable = (lhp) => {
    if (lhp.daDangKy) return true;
    if (lhp.daDay) return false;
    if (lhp.daPass) return false;
    const sameMon = allChosen.find(c => c.id !== lhp.id && c.monHocId === lhp.monHocId);
    if (sameMon) return false;
    return true;
  };

  const conflictsFor = (lhp) => lhpConflicts(lhp, allChosen.filter(c => c.id !== lhp.id));

  const toggle = (lhp) => {
    if (lhp.daDangKy) {
      studentApi.cancel(lhp.dangKyHocId)
        .then(reload)
        .catch(() => message.error('Không thể hủy đăng ký, vui lòng thử lại'));
      return;
    }
    setSelectedIds(prev => {
      const next = new Set(prev);
      next.has(lhp.id) ? next.delete(lhp.id) : next.add(lhp.id);
      return next;
    });
  };

  const submit = async () => {
    if (submittingRef.current || selectedIds.size === 0) return { success: [], failed: [] };
    submittingRef.current = true;
    try {
      const res = await studentApi.register([...selectedIds]);
      await reload();
      return res;
    } finally {
      submittingRef.current = false;
    }
  };

  return { available, allChosen, selectedIds, toggle, tickable, conflictsFor, submit, loading, reload, error };
}
