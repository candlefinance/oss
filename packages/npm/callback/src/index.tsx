const Callback = require('./NativeCallback').default;

export function multiply(a: number, b: number): number {
  return Callback.multiply(a, b);
}
