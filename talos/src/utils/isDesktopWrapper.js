import React, { Component } from 'react';
import { addResizeListenerIsDesktop, isDesktop } from "../services/responsive.service"

class IsDesktopWrapper extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isDesktop: isDesktop()
    }
  }

  componentDidMount() {
    addResizeListenerIsDesktop(this, "isDesktop")
  }

  render() {
    return this.state.isDesktop
      ? this.props.children
      : null
  }
}

export default IsDesktopWrapper
