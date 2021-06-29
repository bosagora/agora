import React from 'react'

import styles from './counterItem.module.scss'

const CounterItem = props => {
  const { index, isActive, onClick } = props

  return (
    <span className={isActive ? styles.counterItemActive : styles.counterItem} onClick={onClick}>
      {index}
    </span>
  )
}

export default React.memo(CounterItem)