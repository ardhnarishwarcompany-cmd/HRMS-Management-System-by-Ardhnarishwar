import { Component } from "react";
import { AlertTriangle, RotateCcw } from "lucide-react";

// Prevents one bad row/field of data from turning an entire page blank.
// Any render-time crash below this boundary is caught and a small,
// recoverable message is shown instead of an unstyled white screen.
export default class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error, info) {
    // eslint-disable-next-line no-console
    console.error("UI error caught by ErrorBoundary:", error, info);
  }

  handleRetry = () => {
    this.setState({ hasError: false });
  };

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex flex-col items-center justify-center text-center py-16 px-6">
          <span className="mb-3 inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-amber-50 text-amber-500">
            <AlertTriangle size={22} />
          </span>
          <p className="text-sm font-semibold text-gray-800">Something went wrong loading this page.</p>
          <p className="mt-1 text-xs text-gray-400 max-w-xs">
            Please try again. If this keeps happening, contact the admin.
          </p>
          <button
            onClick={this.handleRetry}
            className="mt-4 inline-flex items-center gap-1.5 rounded-xl bg-gray-900 text-white px-4 py-2 text-xs font-semibold hover:bg-gray-800"
          >
            <RotateCcw size={13} /> Try again
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}
