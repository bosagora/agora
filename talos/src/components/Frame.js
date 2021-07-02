/**
 * A single frame in the single-page application.
 *
 * The frame can be either a "page" (either 'intro' or 'config'),
 * or a step within 'config'.
 */
import { Component } from 'react';

import { withAppState } from "components/app/State"

export class Frame extends Component {

    constructor(props) {
        super(props);

        this.state = {
            enabled: this.isEnabled(props),
        }
    }

    //
    isDisabled (props) {
        return props.currentIndex !== props.navigationIndex;
    }

    //
    isEnabled (props) {
        return props.currentIndex === props.navigationIndex;
    }

    //
    enable () {
        this.setState({ enabled: true })
    }

    disable () {
        window.scrollTo(0, 0)
        this.setState({ enabled: false })
    }

    componentDidUpdate(prevProps) {
        if (this.isDisabled(prevProps) && this.isEnabled(this.props))
            this.enable();

        if (this.isEnabled(prevProps) && this.isDisabled(this.props))
            this.disable();
    }

    render() {
        return this.state.enabled
            ? this.props.children
            : null;
    }
}

export default withAppState(Frame)
