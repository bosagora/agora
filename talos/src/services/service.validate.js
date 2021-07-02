export const validateDNS = string => {
    const reqExp = /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z0-9]{2,100}(:[0-9]{1,5})?(\/.*)?$/;
    return reqExp.test(string);
}

export const validateNetwork = string => {
    const reqExp = /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z0-9]{2,100}(:[0-9]{1,5})?(\/.*)?$/;
    return reqExp.test(string);
}

export const validateSecretKey = string => {
    const reqExp = /^S[0-9a-z]{55}$/;
    return reqExp.test(string);
}

export const validateAddress = string => {
    const reqExp = /^[A-Za-z0-9.:-@]+$/;
    return reqExp.test(string);
}

export const validatePort = string => {
    const reqExp = /^[0-9]+$/;
    return reqExp.test(string);
}
