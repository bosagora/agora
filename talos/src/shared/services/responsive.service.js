import variables from './../../values.scss'

export const isDesktop = () => {
    return document.body.clientWidth > parseInt(variables.minMediaXS)
}

export const isMobile = () => {
    return document.body.clientWidth <= parseInt(variables.maxMediaXS)
}

export const setToStateDesktop = (context, subStore) => {
    let store = { ...context.state }
    let nowDevice = isDesktop()

    if (nowDevice !== store[subStore]) {
        store[subStore] = isDesktop()
        context.setState(store)
    }
}

export const setToStateMobile = (context, subStore) => {
    let store = { ...context.state }
    let nowDevice = isMobile()

    if (nowDevice !== store[subStore]) {
        store[subStore] = isMobile()
        context.setState(store)
    }
}

export const addResizeListenerIsDesktop = (context, subStore) => {
    window.addEventListener(
        'resize',
        setToStateDesktop.bind(this, context, subStore)
    )
}

export const addResizeListenerIsMobile = (context, subStore) => {
    window.addEventListener(
        'resize',
        setToStateMobile.bind(this, context, subStore)
    )
}
