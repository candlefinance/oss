const Cache = require('./NativeCache').default;

export function multiply(a: number, b: number): number {
  return Cache.multiply(a, b);
}
