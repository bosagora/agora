import React from 'react'

const MultiIcon = props => {
  const { name, path } = props
  const pathArr = path.split(', ')

  return (
    <span className={`icon icon-${name}`}>
      {
        pathArr.map((item, index) => {
          return <span className={item} key={index}></span>
        })
      }
    </span>
  )
}

export default React.memo(MultiIcon)