import { Eye, EyeOff } from 'lucide-react';
import { Input } from 'antd';
import { useState } from 'react';

/**
 * PasswordInput Component (Requirement 21)
 * 
 * Password input field with eye icon toggle for visibility.
 * Compatible with Ant Design Form.Item.
 * 
 * @param {Object} props - All standard Input props are forwarded
 */
export default function PasswordInput({ value, onChange, placeholder, ...rest }) {
  const [visible, setVisible] = useState(false);

  return (
    <div style={{ position: 'relative' }}>
      <Input
        type={visible ? 'text' : 'password'}
        value={value}
        onChange={onChange}
        placeholder={placeholder}
        style={{ paddingRight: 40 }}
        {...rest}
      />
      <button
        type="button"
        onClick={() => setVisible(!visible)}
        style={{
          position: 'absolute',
          right: 8,
          top: '50%',
          transform: 'translateY(-50%)',
          border: 'none',
          background: 'none',
          cursor: 'pointer',
          padding: 8,
          display: 'flex',
          alignItems: 'center',
          color: visible ? '#555' : '#999',
          transition: 'color 150ms',
        }}
        onMouseEnter={(e) => e.currentTarget.style.color = '#555'}
        onMouseLeave={(e) => e.currentTarget.style.color = visible ? '#555' : '#999'}
        tabIndex={-1}
        aria-label={visible ? 'Hide password' : 'Show password'}
      >
        {visible ? <EyeOff size={16} /> : <Eye size={16} />}
      </button>
    </div>
  );
}
