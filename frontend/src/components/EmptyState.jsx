import { FileText } from 'lucide-react';

/**
 * EmptyState Component
 * 
 * A reusable component for displaying empty states with an icon and message.
 * Used when no data is available to display in a view.
 * 
 * @param {Object} props
 * @param {React.ReactNode} [props.icon] - Custom icon to display (default: FileText)
 * @param {string} props.message - Primary message to display
 * @param {string} [props.description] - Optional secondary description text
 * 
 * @example
 * <EmptyState 
 *   message="No grades available yet"
 *   description="Grades will appear here after your first semester."
 * />
 */
export default function EmptyState({ 
  icon = <FileText size={48} />, 
  message, 
  description 
}) {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '60px 20px',
      color: '#999',
      textAlign: 'center'
    }}>
      {/* Icon display with muted color */}
      <div style={{ 
        color: '#d9d9d9', 
        marginBottom: 16,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }}>
        {icon}
      </div>
      
      {/* Primary message */}
      <div style={{ 
        fontSize: 14, 
        fontWeight: 500, 
        marginBottom: description ? 8 : 0,
        color: '#999'
      }}>
        {message}
      </div>
      
      {/* Optional description */}
      {description && (
        <div style={{ 
          fontSize: 12, 
          color: '#bbb',
          maxWidth: 400,
          lineHeight: 1.5
        }}>
          {description}
        </div>
      )}
    </div>
  );
}
