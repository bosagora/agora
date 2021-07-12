export const validateDNS = string => {
    const reqExp = /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([-.]{1}[a-z0-9]+)*\.[a-z0-9]{2,100}(:[0-9]{1,5})?(\/.*)?$/;
    return reqExp.test(string);
}

export const parseBindAddress = string => {
    const prefixes = [ "https", "http", "tcp" ];

    // Default values for the scheme and the port
    // Only the bind address is required to be provided.
    let result = {
        // TODO: Change to 'tcp'
        type: "http",
        address: string,
        port: 2826,
    }

    const defaultError = {
        error: "Expected an IPv4 bind address with an optional prefix and port, e.g. 'http://0.0.0.0:2826'",
    };

    if (typeof(string) !== "string")
        return defaultError;

    for (const element of prefixes) {
        if (string.startsWith(element + "://"))
        {
            result.type = element;
            result.address = string.slice(element.length + 3);
            break;
        }
    }

    // Parse port
    const sp = result.address.split(":");
    if (sp.length > 2)
        return defaultError;
    if (sp.length === 2)
    {
        const port = parseInt(sp[1]);
        if (port > 0 && port <= 65535)
            result.port = port;
        else
            return { error: `${sp[1]} is not a valid value for a port (expected 0-65536)` };
    }
    result.address = sp[0];

    // Parse IP (it's actually a netmask)
    const ip = result.address.split('.');
    if (ip.length !== 4)
        return defaultError;

    for (const element of ip)
    {
        if (element >= 0 && element <= 255)
            continue;
        return { error: `${ip[0]} is not a valid IPv4 bind address (value ${element} is out of the 0-255 range)` };
    }

    return result;
}

export const validateNetwork = string => {
    const result = parseBindAddress(string);
    return 'error' in result ? false : true;
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
