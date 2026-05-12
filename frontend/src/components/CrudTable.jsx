import { useState } from 'react';
import { Table, Button, Space, Modal, Form, Popconfirm, message } from 'antd';
import { Plus, Pencil, Trash2 } from 'lucide-react';

export default function CrudTable({
  columns, dataSource, rowKey = 'id', loading,
  onCreate, onUpdate, onDelete,
  renderForm, modalTitle = 'Thêm', toFormValues = (r) => r,
}) {
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form] = Form.useForm();

  const openCreate = () => { setEditing(null); form.resetFields(); setOpen(true); };
  const openEdit = (row) => { setEditing(row); form.setFieldsValue(toFormValues(row)); setOpen(true); };

  const submit = async () => {
    const values = await form.validateFields();
    try {
      if (editing) await onUpdate(editing[rowKey], values);
      else await onCreate(values);
      message.success('Đã lưu');
      setOpen(false);
    } catch (e) { message.error(e?.response?.data?.error?.message ?? 'Lỗi'); }
  };

  const allCols = [
    ...columns,
    {
      title: 'Hành động', width: 160, render: (_, row) => (
        <Space>
          <Button size="small" icon={<Pencil size={14}/>} onClick={() => openEdit(row)}/>
          <Popconfirm title="Xóa?" onConfirm={() => onDelete(row[rowKey]).catch(e => message.error(e?.response?.data?.error?.message ?? 'Lỗi'))}>
            <Button size="small" danger icon={<Trash2 size={14}/>}/>
          </Popconfirm>
        </Space>
      )
    }
  ];

  return (
    <>
      <div style={{ marginBottom: 12 }}>
        <Button type="primary" icon={<Plus size={14}/>} onClick={openCreate}>Thêm</Button>
      </div>
      <Table rowKey={rowKey} dataSource={dataSource} columns={allCols} loading={loading} size="small"/>
      <Modal title={editing ? 'Sửa' : modalTitle} open={open} onOk={submit} onCancel={() => setOpen(false)} destroyOnClose>
        <Form form={form} layout="vertical">{renderForm({ form, editing })}</Form>
      </Modal>
    </>
  );
}
