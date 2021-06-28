import React, { Component } from 'react'
import { get, isEqual, has } from "lodash"
import TokenInput from 'react-customize-token-input';
import 'react-customize-token-input/dist/react-customize-token-input.css';

import Icon from "./../static/icon"

import styles from "./tokenInputWrapper.module.scss"

class TokenInputWrapper extends Component {
  componentDidMount() {
    const { name, onChange, valueStore } = this.props

    if (!has(valueStore, [name]))
      onChange(name, get(this.props, ["defaultValue"], []), false)
  }

  handleKeyDown(props, e) {
    const { onEndEdit } = props
    const { value } = e.target;

    if (e.keyCode === 13) {// Enter key
      onEndEdit(value)
    }
  }

  handleBlur(props, e) {
    const { onEndEdit, onDelete } = props
    const { value } = e.target;

    value.length === 0
      ? onDelete()
      : onEndEdit(value)
  }

  handleValidate(data) {
    const { validateAction } = this.props

    return !validateAction(data)
  }

  tokenRender(props) {
    const {
      key,
      data,
      meta,
      onStartEdit,
      onDelete
    } = props;

    const { activated, error } = meta;

    // if (activated) {
    //   return (
    //     <div key={key} className={styles.tokenItemWrapper}>
    //       <div className={styles.tokenItem}>
    //         <div className={error ? styles.container_tokenItemInnerError : styles.container_tokenItemInner}>
    //           <input
    //             className={styles.editInput}
    //             ref={input => input && input.focus()}
    //             defaultValue={data}
    //             onKeyDown={this.handleKeyDown.bind(this, props)}
    //             onBlur={this.handleBlur.bind(this, props)}
    //           />
    //         </div>
    //         <div className={styles.container_closeButton}>
    //           <Icon name="close" />
    //         </div>
    //       </div>
    //     </div>
    //   );
    // }

    return (
      <div key={key} className={styles.tokenItemWrapper}>
        <div className={styles.tokenItem}>
          <div className={error ? styles.container_tokenItemInnerError : styles.container_tokenItemInner} onClick={() => onStartEdit()}>
            <span className={styles.tokenTitle}>{data}</span>
          </div>
          <div className={styles.container_closeButton} onClick={() => onDelete()}>
            <Icon name="close" />
          </div>
        </div>
      </div>
    );
  }

  onChangeToken(tokens) {
    const { onChange, valueStore, name, } = this.props

    if (!isEqual(get(valueStore, [name, "value"], []), tokens))
      onChange(name, tokens, true)
  }

  render() {
    const { label, valueStore, name, validateAction } = this.props
    var content = get(valueStore, [name, "value"], [])
    var wrapperClassName = styles.tokenInputWrapper

    if (!get(valueStore, [name, "isValid"], true))
      wrapperClassName = styles.tokenInputWrapperError

    const defaultValue = get(
      valueStore, [name, "value"],
      get(this.props, ["defaultValue"], [])
    )

    return (
      <div className={wrapperClassName}>
        <TokenInput
          defaultData={defaultValue.map(item => item.value)}
          className={content.length === 0 ? styles.tokenInputNull : styles.tokenInput}
          separators={[' ']}
          onTokensUpdate={this.onChangeToken.bind(this)}
          tokenRender={this.tokenRender.bind(this)}
          validator={!!validateAction ? this.handleValidate.bind(this) : null}
        />
        <span className={content.length > 0 ? styles.tokenInputLabelActive : styles.tokenInputLabel}>{label}</span>

        <span className={styles.tokenInputErrorLabel}>{get(valueStore, [name, "validString"], "")}</span>
      </div>
    )
  }
}

export default React.memo(TokenInputWrapper)
