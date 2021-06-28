import React from 'react'

const Icon = props => {
  const { name } = props

  return (
    <span className={`icon icon-${name}`}></span>
  )
}

export default React.memo(Icon)