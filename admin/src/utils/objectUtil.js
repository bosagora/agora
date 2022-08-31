export function isEmptyObject(param) {
  return Object.keys(param).length === 0 && param.constructor === Object;
}
