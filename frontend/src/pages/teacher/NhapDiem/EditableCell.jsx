import { InputNumber } from 'antd';

export default function EditableCell({ value, onChange }) {
  return (
    <InputNumber min={0} max={10} step={0.5} value={value ?? null}
      onChange={onChange} style={{ width: 80 }} placeholder="–" />
  );
}
