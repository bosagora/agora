import React from 'react'

import Icon from "./icon"
import ButtonFill from "./../controls/buttonFill"

import styles from "./nextButton.module.scss"

const NextButton = props => {
  return (
    <ButtonFill>
      <div className={styles.nextButton}>
        {props.children}
        <div className={styles.container_icon}>
          <Icon name="arrow-right" />
        </div>
      </div>
    </ButtonFill>
  )
}

export default React.memo(NextButton)