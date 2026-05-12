import { Select } from 'antd';
import { useEffect, useState } from 'react';
import { commonApi } from '../../../../api/endpoints/common';

export default function SemesterSelect({ value, onChange }) {
  const [opts, setOpts] = useState([]);
  useEffect(() => {
    commonApi.kiHocList().then(d => {
      setOpts(d);
      if (!value && d.length) onChange(d[0].id);
    }).catch(console.error);
  }, []);
  return (
    <Select style={{ width: 240 }} value={value} onChange={onChange}
      options={opts.map(k => ({ value: k.id, label: k.ten }))} />
  );
}
