/** @see https://github.com/Microsoft/TypeScript/issues/19244#issuecomment-337552457 */
type Stringified<T> = string &
  {
    [P in keyof T]: { '_ value': T[P] };
  };

/** @see https://github.com/Microsoft/TypeScript/issues/19244#issuecomment-337552457 */
interface JSON {
  // stringify(value: any, replacer?: (key: string, value: any) => any, space?: string | number): string;
  stringify<T>(
    value: T,
    replacer?: (key: string, value: any) => any,
    space?: string | number
  ): string & Stringified<T>;
  // parse(text: string, reviver?: (key: any, value: any) => any): any;
  parse<T>(text: Stringified<T>, reviver?: (key: any, value: any) => any): T;
}

type AdPlaceholderTrackerAction = 'add' | 'update' | 'remove';

interface AdPlaceholderTrackerMessage {
  id: string;
  action: AdPlaceholderTrackerAction;
  rect?: DOMRect;
}

interface AdPlaceholderTracker {
  postMessage?(message: Stringified<AdPlaceholderTrackerMessage>): void;
}

interface Window {
  webkit?: {
    messageHandlers?: {
      adPlaceholderTracker?: AdPlaceholderTracker;
    };
  };
}

const adPlaceholderTracker: AdPlaceholderTracker | undefined;
