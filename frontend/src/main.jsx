import React from 'react';
import ReactDOM from 'react-dom/client';
import { ConfigProvider } from 'antd';
import 'antd/dist/reset.css';
import './styles/global.css';
import './styles/animations.css';
import App from './App';

const theme = {
    token: {
        colorPrimary: '#C00000',
        colorInfo: '#C00000',
        borderRadius: 6,
        fontFamily: "-apple-system, 'Segoe UI', Roboto, sans-serif",
    },
    components: {
        Button: { primaryShadow: 'none' },
        Table: { headerBg: '#FFE5E5', headerColor: '#800000' },
    }
};

ReactDOM.createRoot(document.getElementById('root')).render(
    <React.StrictMode>
        <ConfigProvider theme={theme}>
            <App />
        </ConfigProvider>
    </React.StrictMode>
);
