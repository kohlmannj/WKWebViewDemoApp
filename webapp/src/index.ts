function adPlaceholderTrackerPostMessage(message: AdPlaceholderTrackerMessage): void {
  let tracker;

  if (typeof adPlaceholderTracker !== 'undefined') {
    tracker = adPlaceholderTracker;
  } else if (typeof window !== 'undefined') {
    tracker = window.webkit?.messageHandlers?.adPlaceholderTracker;
  }

  tracker?.postMessage?.(JSON.stringify(message));
}

const adPlaceholderRequests: Record<string, number> = {};

function trackAdPlaceholder(element: Element, initial?: boolean): void {
  adPlaceholderTrackerPostMessage({
    id: element.id,
    action: initial ? 'add' : 'update',
    rect: element.getBoundingClientRect(),
  });
}

function startTrackingAdPlaceholders(): void {
  document.querySelectorAll('.ad-placeholder').forEach((adPlaceholder) => {
    let initial = true;
    function adPlaceholderCallback() {
      trackAdPlaceholder(adPlaceholder, initial);
      initial = false;
      window.requestAnimationFrame(adPlaceholderCallback);
    }

    adPlaceholderRequests[adPlaceholder.id] = window.requestAnimationFrame(adPlaceholderCallback);
  });
}

function stopTrackingAdPlaceholders(): void {
  Object.keys(adPlaceholderRequests).forEach((id, index) => {
    const requestId = adPlaceholderRequests[id];
    window.cancelAnimationFrame(requestId);
    adPlaceholderTrackerPostMessage({ id, action: 'remove' });
    delete adPlaceholderRequests[id];
  });
}

window.addEventListener('message', ({ data }) => {
  switch (data) {
    case 'startTrackingAdPlaceholders':
      startTrackingAdPlaceholders();
      break;
    case 'stopTrackingAdPlaceholders':
      stopTrackingAdPlaceholders();
      break;
    default:
      console.warn(`Received unknown message: ${JSON.stringify(data)}`);
      break;
  }
});
