function writeLog(level, message, extra = {}) {
  const payload = {
    timestamp: new Date().toISOString(),
    level,
    service: 'gym-backend',
    message,
    ...extra
  };

  const serializedPayload = JSON.stringify(payload);

  if (level === 'error') {
    console.error(serializedPayload);
    return;
  }

  console.log(serializedPayload);
}

function logInfo(message, extra = {}) {
  writeLog('info', message, extra);
}

function logError(message, extra = {}) {
  writeLog('error', message, extra);
}

module.exports = {
  logInfo,
  logError
};
