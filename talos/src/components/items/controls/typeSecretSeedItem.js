import React, { Component } from 'react';

import styles from "./typeSecretSeedItem.module.scss"

class TypeSecrerSeedItem extends Component {
  render() {
    const { icon, title, onClick, index, currentIndex } = this.props

    return (
      <div
        className={index === currentIndex ? styles.chooseTypeItemActive : styles.chooseTypeItem}
        onClick={() => onClick(index)}
      >
        <div className={styles.container_icon}>
          {icon}
        </div>
        <div styles={styles.container_title}>
          {title}
        </div>
      </div >
    )
  }
}

export default TypeSecrerSeedItem