import React, { Component } from 'react';
import { get, has } from "lodash"

import styles from "./typeSecretSeedItem.module.scss"

class TypeSecrerSeedItem extends Component {
  componentDidMount() {
    const { checked, onClick, name, value, valueStore } = this.props

    if (!has(valueStore, [name, "value"]) && checked)
      onClick(name, value)
  }

  render() {
    const { name, value, icon, title, valueStore, onClick } = this.props

    return (
      <div
        className={get(valueStore, [name, "value"], "") === value ? styles.chooseTypeItemActive : styles.chooseTypeItem}
        onClick={get(valueStore, [name, "value"], "") !== value ? onClick.bind(this, name, value) : () => { }}
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