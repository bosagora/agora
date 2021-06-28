import React, { Component } from 'react';

import { withAppState } from "./../../shared/containers/containerAppState"

import SecondTitle from "./../../shared/items/static/secondTitle"
import FirstTitleExtra from "./../../shared/items/static/firstTitleExtra"
import NextDefaultButton from "./../../shared/items/static/nextDefaultButton"
import ButtonFillDefault from "./../../shared/items/controls/buttonFillDefault"
import Paragraph from "./../../shared/items/static/paragraph"
import ParagraphTitle from "./../../shared/items/static/paragraphTitle"
import Icon from "./../../shared/items/static/icon"

import styles from "./preview.module.scss"

class Preview extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isOpen: true
    }
  }

  componentDidUpdate(prevProps) {
    const { isOrderOn } = this.props

    if (prevProps.isOrderOn && !isOrderOn)
      this.setState({ isOpen: true })

    if (!prevProps.isOrderOn && isOrderOn) {
      window.scrollTo(0, 0)
      setTimeout(function () {
        this.setState({ isOpen: false })
      }.bind(this), 1000)
    }
  }

  render() {
    const { isOrderOn, onOpenAppOrder } = this.props

    return this.state.isOpen
      ?
      <div className={!isOrderOn ? styles.preview : styles.previewHidden}>
        <div className={styles.previewInner}>
          <div className={styles.container_sideLeft}>
            <div className={styles.sideLeftContainer}>
              <div className={styles.container_mainTitle}>
                <FirstTitleExtra>Welcome to the Talos <br />Admin Interface</FirstTitleExtra>
              </div>
              <div className={styles.container_logo}>
                <Icon name="logo" />
              </div>
            </div>
          </div>
          <div className={styles.container_sideRight}>
            <div className={styles.sideRightContainer}>
              <div className={styles.container_secondTitle}>
                <ParagraphTitle>The Talos desktop and mobile Admin Interface</ParagraphTitle>
              </div>
              <div className={styles.container_content}>
                <Paragraph>a highly secure and intuitive user interface that is quick and easy to use. This interface will assist you in the setup and management of your very own AGORA Validator or Full Node. Please follow the directions on the following screens to become part of AGORA. Whether you're setting up a new Validator or Full Node or managing your existing one – BOSAGORA has made it as easy as possible.</Paragraph>
              </div>
              <div className={styles.container_nextButton}>
                <ButtonFillDefault onClick={onOpenAppOrder}>
                  <NextDefaultButton>Continue</NextDefaultButton>
                </ButtonFillDefault>
              </div>
            </div>
          </div>
        </div>
      </div>
      : null
  }
}

export default withAppState(Preview)
