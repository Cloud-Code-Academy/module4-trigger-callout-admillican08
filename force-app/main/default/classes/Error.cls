public with sharing class Error {
    public String message { get; private set; }
    public String stackTrace { get; private set; }
    public String className { get; private set; }
    public String methodName { get; private set; }
    public Integer lineNumber { get; private set; }
    public DateTime timestamp { get; private set; }
    public String errorType { get; private set; }
    
    public Error(Exception ex) {
        this.message = ex.getMessage();
        this.stackTrace = ex.getStackTraceString();
        this.timestamp = DateTime.now();
        this.errorType = ex.getTypeName();
        parseStackTrace();
    }
    
    public Error(String message, String className, String methodName) {
        this.message = message;
        this.className = className;
        this.methodName = methodName;
        this.timestamp = DateTime.now();
        this.errorType = 'CustomError';
    }
    
    private void parseStackTrace() {
        if (String.isNotBlank(this.stackTrace)) {
            List<String> lines = this.stackTrace.split('\n');
            if (!lines.isEmpty()) {
                String firstLine = lines[0];
                if (firstLine.contains(':')) {
                    List<String> parts = firstLine.split(':');
                    if (parts.size() >= 2) {
                        this.className = parts[0].trim();
                        if (parts[1].contains('.')) {
                            List<String> methodParts = parts[1].split('\\.');
                            this.methodName = methodParts[0].trim();
                            if (methodParts.size() > 1) {
                                try {
                                    this.lineNumber = Integer.valueOf(methodParts[1].replaceAll('\\D', ''));
                                } catch (Exception e) {
                                    this.lineNumber = null;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public String getFormattedError() {
        String result = '[' + this.timestamp.format('yyyy-MM-dd HH:mm:ss') + '] ';
        result += this.errorType + ': ' + this.message;
        if (String.isNotBlank(this.className)) {
            result += ' (Class: ' + this.className;
            if (String.isNotBlank(this.methodName)) {
                result += ', Method: ' + this.methodName;
            }
            if (this.lineNumber != null) {
                result += ', Line: ' + this.lineNumber;
            }
            result += ')';
        }
        return result;
    }
    
    public void logError() {
        System.debug(LoggingLevel.ERROR, getFormattedError());
        if (String.isNotBlank(this.stackTrace)) {
            System.debug(LoggingLevel.DEBUG, 'Stack Trace: ' + this.stackTrace);
        }
    }
}