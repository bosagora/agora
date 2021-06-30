import React, { Component } from 'react';

import { withAppState } from "../steps/AppState"

import SecondTitle from "../items/static/secondTitle"
import FirstTitleExtra from "../items/static/firstTitleExtra"
import NextDefaultButton from "../items/static/nextDefaultButton"
import ButtonFillDefault from "../items/controls/buttonFillDefault"
import Paragraph from "../items/static/paragraph"
import ParagraphTitle from "../items/static/paragraphTitle"
import Icon from "../items/static/icon"

import styles from "./preview.module.scss"

class Preview extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isOpen: true
    }
  }

  componentDidUpdate(prevProps) {
    const { currentIndex } = this.props

    if (prevProps.currentIndex > 0 && currentIndex === 0)
      this.setState({ isOpen: true })

    if (prevProps.currentIndex === 0 && currentIndex > 0) {
      window.scrollTo(0, 0)
      setTimeout(function () {
        this.setState({ isOpen: false })
      }.bind(this), 1000)
    }
  }

  render() {
    const { currentIndex, onToNextStep } = this.props

    return this.state.isOpen
      ?
      <div className={currentIndex === 0 ? styles.preview : styles.previewHidden}>
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
                <ButtonFillDefault onClick={onToNextStep}>
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
