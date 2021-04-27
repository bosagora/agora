export const validateDNS = string => {
  const reqExp = new RegExp("^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z0-9]{2,100}(:[0-9]{1,5})?(\/.*)?$")

  return reqExp.test(string)
}

export const validateNetwork = string => {
  const reqExp = new RegExp("^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z0-9]{2,100}(:[0-9]{1,5})?(\/.*)?$")

  return reqExp.test(string)
}

export const validatSecretKey = string => {
  const reqExp = new RegExp('^S[0-9a-z]{55}$');

  return reqExp.test(string)
}

export const validateAddress = string => {
  const reqExp = new RegExp("^[A-Za-z0-9\.\:\-\@]+$")

  return reqExp.test(string)
}

export const validatePort = string => {
  const reqExp = new RegExp("^[0-9]+$")

  return reqExp.test(string)
}
