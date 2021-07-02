import React, { Component } from 'react';
import { steps } from "./static"

import { withAppState } from "components/app/State"

import ButtonStaticStep from "components/items/controls/buttonStaticStep"
import ScrollHorizontalMenuWrapper from "../items/controls/scrollHorizontalMenuWrapper"
import Icon from "components/items/static/icon"

import styles from './mobileMenuList.module.scss'

class MobileMenuList extends Component {
  constructor(props) {
    super(props);

    this.scrollToStep = this.scrollToStep.bind(this)
  }
  componentDidMount() {
    const { currentIndex } = this.props

    this.scrollToStep(currentIndex)
  }

  componentDidUpdate(prevProps) {
    const { currentIndex } = this.props

    if (prevProps.currentIndex !== currentIndex)
      this.scrollToStep(currentIndex)
  }

  scrollToStep(currentIndex) {
    const { scrollbars } = this.refs

    switch (currentIndex) {
      case steps.validator:
        scrollbars.scrollLeft(document.querySelector("#validator_wrapper").offsetLeft)
        return null;

      case steps.network:
        scrollbars.scrollLeft(document.querySelector("#network_wrapper").offsetLeft - 36)
        return null;

      case steps.banman:
        scrollbars.scrollLeft(document.querySelector("#banman_wrapper").offsetLeft - 36)
        return null;

      case steps.admin:
        scrollbars.scrollLeft(document.querySelector("#admin_wrapper").offsetLeft - 36)
        return null;

      default:
        return null
    }
  }

  render() {
    const { currentIndex } = this.props

    return (
      <div className={styles.mobileMenuListWrapper}>

        <div className={styles.container_check}>
          <Icon name="arrow-right" />
        </div>

        <ScrollHorizontalMenuWrapper
          ref="scrollbars"
        >
          <div className={styles.mobileMenuList}>
            <div className={styles.mobileMenuItemWrapper} id="validator_wrapper">
              <ButtonStaticStep currentIndex={currentIndex} stepIndex={steps.validator}>Secret Seed</ButtonStaticStep>
            </div>

            <div className={styles.mobileMenuItemWrapper} id="network_wrapper">
              <ButtonStaticStep currentIndex={currentIndex} stepIndex={steps.network}>Network Options</ButtonStaticStep>
            </div>

            <div className={styles.mobileMenuItemWrapper} id="banman_wrapper">
              <ButtonStaticStep currentIndex={currentIndex} stepIndex={steps.banman}>Ban Management</ButtonStaticStep>
            </div>

            <div className={styles.mobileMenuItemWrapper} id="admin_wrapper">
              <ButtonStaticStep currentIndex={currentIndex} stepIndex={steps.admin}>Administrative Interface</ButtonStaticStep>
            </div>
          </div>
        </ScrollHorizontalMenuWrapper>

      </div>
    )
  }
}

export default withAppState(MobileMenuList)
