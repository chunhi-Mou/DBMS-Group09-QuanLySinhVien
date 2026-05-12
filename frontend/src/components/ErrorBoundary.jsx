import React from 'react';
import { AlertTriangle } from 'lucide-react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null, errorInfo: null };
  }

  componentDidCatch(error, errorInfo) {
    // Log error details to console for debugging
    console.error('ErrorBoundary caught an error:', error, errorInfo);
    
    // Update state to display fallback UI
    this.setState({
      hasError: true,
      error: error,
      errorInfo: errorInfo
    });
  }

  handleReturnToLogin = () => {
    // Clear authentication state
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    
    // Redirect to login page
    window.location.href = '/login';
  };

  render() {
    if (this.state.hasError) {
      // Fallback UI matching application design system
      return (
        <div style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          minHeight: '400px',
          padding: '40px 24px'
        }}>
          <div style={{
            background: 'var(--color-surface)',
            border: '1px solid var(--color-border)',
            borderRadius: 'var(--radius)',
            padding: '32px',
            maxWidth: '500px',
            width: '100%',
            textAlign: 'center',
            boxShadow: 'var(--shadow-md)'
          }}>
            <div style={{
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              width: '64px',
              height: '64px',
              borderRadius: '50%',
              background: 'var(--color-primary-light)',
              marginBottom: '20px'
            }}>
              <AlertTriangle size={32} color="var(--color-primary)" />
            </div>

            <h2 style={{
              fontSize: '20px',
              fontWeight: 700,
              color: 'var(--color-text)',
              fontFamily: 'var(--font-display)',
              marginBottom: '12px'
            }}>
              Đã xảy ra lỗi
            </h2>

            <p style={{
              fontSize: '14px',
              color: 'var(--color-text-muted)',
              marginBottom: '24px',
              lineHeight: 1.6
            }}>
              Ứng dụng gặp sự cố không mong muốn. Vui lòng đăng nhập lại để tiếp tục.
            </p>

            <button
              onClick={this.handleReturnToLogin}
              style={{
                background: 'var(--color-primary)',
                color: 'white',
                border: 'none',
                borderRadius: 'var(--radius)',
                padding: '10px 24px',
                fontSize: '14px',
                fontWeight: 600,
                fontFamily: 'var(--font-display)',
                cursor: 'pointer',
                transition: 'background var(--duration-fast) var(--ease-out)',
                boxShadow: 'var(--shadow-sm)'
              }}
              onMouseEnter={(e) => e.target.style.background = 'var(--color-primary-hover)'}
              onMouseLeave={(e) => e.target.style.background = 'var(--color-primary)'}
            >
              Quay về trang đăng nhập
            </button>

            {process.env.NODE_ENV === 'development' && this.state.error && (
              <details style={{
                marginTop: '24px',
                textAlign: 'left',
                fontSize: '12px',
                color: 'var(--color-text-muted)',
                background: 'var(--color-bg)',
                padding: '12px',
                borderRadius: 'var(--radius)',
                border: '1px solid var(--color-border)'
              }}>
                <summary style={{ cursor: 'pointer', fontWeight: 600, marginBottom: '8px' }}>
                  Chi tiết lỗi (chỉ hiển thị trong môi trường phát triển)
                </summary>
                <pre style={{
                  whiteSpace: 'pre-wrap',
                  wordBreak: 'break-word',
                  fontSize: '11px',
                  margin: 0
                }}>
                  {this.state.error.toString()}
                  {this.state.errorInfo && this.state.errorInfo.componentStack}
                </pre>
              </details>
            )}
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
