import { Tag, Tooltip } from 'antd';
import { CheckSquare, Square } from 'lucide-react';
import s from '../styles.module.css';

export default function LhpRow({ lhp, selected, disabled, conflictCount, onToggle }) {
  let cls = s.row;
  if (selected) cls += ' ' + s.selected;
  if (disabled) cls += ' ' + s.disabled;
  if (conflictCount > 0 && !disabled) cls += ' ' + s.conflict;

  const tooltip = lhp.daDay ? 'Đã đủ sinh viên'
    : lhp.daPass ? 'Đã hoàn thành'
    : disabled ? 'Đã chọn lớp khác cùng môn'
    : conflictCount > 0 ? `Trùng ${conflictCount} buổi với lớp đã chọn`
    : '';

  return (
    <Tooltip title={tooltip}>
      <div className={cls} onClick={() => !disabled && onToggle()}>
        <span className={s.icon}>{selected ? <CheckSquare size={16} style={{ color: 'var(--color-primary)' }} /> : <Square size={16} style={{ color: '#bbb' }} />}</span>
        <span className={s.ten}>{lhp.ten}</span>
        <span className={s.siso}>{lhp.siSoHienTai}/{lhp.siSoToiDa}</span>
        <Tag color={lhp.loai === 'BB' ? 'red' : 'default'}>{lhp.loai}</Tag>
      </div>
    </Tooltip>
  );
}
