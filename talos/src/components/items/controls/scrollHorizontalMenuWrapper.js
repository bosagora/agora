import React, { Component } from 'react';
import { Scrollbars } from 'react-custom-scrollbars';
import { SpringSystem, MathUtil } from 'rebound';

import styles from "./scrollHorizontalMenuWrapper.module.scss"

class ScrollHorizontalMenuWrapper extends Component {
  constructor(props, ...rest) {
    super(props, ...rest);

    this.handleSpringUpdate = this.handleSpringUpdate.bind(this);
  }

  componentDidMount() {
    this.springSystem = new SpringSystem();
    this.spring = this.springSystem.createSpring(10, 7);
    this.spring.addListener({ onSpringUpdate: this.handleSpringUpdate });
  }

  componentWillUnmount() {
    this.springSystem.deregisterSpring(this.spring);
    this.springSystem.removeAllListeners();
    this.springSystem = undefined;
    this.spring.destroy();
    this.spring = undefined;
  }

  handleSpringUpdate(spring) {
    const { scrollbars } = this.refs;

    const val = spring.getCurrentValue();
    scrollbars.scrollLeft(val);
  }

  scrollLeft(left) {
    this.spring.setEndValue(left);
  }

  render() {
    return (
      <div className={styles.scrollHorizontalMenuWrapper}>
        <div className={styles.overlay}></div>
        <Scrollbars
          style={{ height: "30px" }}
          autoHide={true}
          ref="scrollbars"
          renderThumbHorizontal={props => <div {...props} className={styles.thumb_horizontal}/>}
        >
          {this.props.children}
        </Scrollbars>
      </div>
    )
  }
}

export default ScrollHorizontalMenuWrapper

