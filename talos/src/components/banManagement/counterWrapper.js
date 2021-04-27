import React, { Component } from 'react'
import { has, get } from 'lodash';

import CounterItem from "./../../shared/items/controls/counterItem"

import styles from './counterWrapper.module.scss'

class CounterWrapper extends Component {
  componentDidMount() {
    const { onChange, name, defaultValue, valueStore } = this.props

    if (!!onChange && !has(valueStore, [name, "value"]))
      onChange(name, get(valueStore, [name, "value"], defaultValue), false)
  }

  render() {
    const { onChange, items, name, valueStore } = this.props

    return (
      <div className={styles.counterWrapper}>
        {
          items.map((item, index) => {
            return (
              <div className={styles.counterItemWrapper} key={item}>
                <CounterItem
                  name={name}
                  index={item}
                  isActive={has(valueStore, [name, "value"]) ? item === get(valueStore, [name, "value"], items[1]) : false}
                  onClick={has(this.props, "onChange") ? onChange.bind(this, name, item, true) : () => { }}
                />
              </div>
            )
          })
        }
      </div>
    )
  }
}

export default React.memo(CounterWrapper)
