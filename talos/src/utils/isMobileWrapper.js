import { Component } from 'react';
import { addResizeListenerIsMobile, isMobile } from "../services/responsive.service"

class IsMobileWrapper extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isMobile: isMobile()
    }
  }

  componentDidMount() {
    addResizeListenerIsMobile(this, "isMobile")
  }

  render() {
    return this.state.isMobile
      ? this.props.children
      : null
  }
}

export default IsMobileWrapper
