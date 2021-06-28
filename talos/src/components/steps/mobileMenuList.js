import React, { Component } from 'react';
import { steps } from "./static"

import { withStepsState } from "./Container"

import ButtonStaticStep from "../items/controls/buttonStaticStep"
import ScrollHorizontalMenuWrapper from "../items/controls/scrollHorizontalMenuWrapper"
import Icon from "../items/static/icon"

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
      case steps.secretSeed:
        scrollbars.scrollLeft(document.querySelector("#secretSeed_wrapper").offsetLeft)
        return null;

      case steps.networkOptions:
        scrollbars.scrollLeft(document.querySelector("#networkOptions_wrapper").offsetLeft - 36)
        return null;

      case steps.banManagement:
        scrollbars.scrollLeft(document.querySelector("#banManagement_wrapper").offsetLeft - 36)
        return null;

      case steps.administrativeInterface:
        scrollbars.scrollLeft(document.querySelector("#administrativeInterface_wrapper").offsetLeft - 36)
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
            <div className={styles.mobileMenuItemWrapper} id="secretSeed_wrapper">
              <ButtonStaticStep currentIndex={currentIndex} stepIndex={steps.secretSeed}>Secret Seed</ButtonStaticStep>
            </div>

            <div className={styles.mobileMenuItemWrapper} id="networkOptions_wrapper">
              <ButtonStaticStep currentIndex={currentIndex} stepIndex={steps.networkOptions}>Network Options</ButtonStaticStep>
            </div>

            <div className={styles.mobileMenuItemWrapper} id="banManagement_wrapper">
              <ButtonStaticStep currentIndex={currentIndex} stepIndex={steps.banManagement}>Ban Management</ButtonStaticStep>
            </div>

            <div className={styles.mobileMenuItemWrapper} id="administrativeInterface_wrapper">
              <ButtonStaticStep currentIndex={currentIndex} stepIndex={steps.administrativeInterface}>Administrative Interface</ButtonStaticStep>
            </div>
          </div>
        </ScrollHorizontalMenuWrapper>

      </div>
    )
  }
}

export default withStepsState(MobileMenuList)
