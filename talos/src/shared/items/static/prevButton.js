import React from 'react'

import Icon from "./icon"
import ButtonText from "./../controls/buttonText"

import styles from "./prevButton.module.scss"

const PrevButton = props => {
  return (
    <ButtonText>
      <div className={styles.prevButton}>
        <div className={styles.container_icon}>
          <Icon name="arrow-left" />
        </div>
        {props.children}
      </div>
    </ButtonText>
  )
}

export default React.memo(PrevButton)