import React from 'react'
import Popover from '@material-ui/core/Popover';
import { withStyles } from '@material-ui/core/styles';

import PopoverButton from './popoverButton';
import Icon from './../static/icon';
import PopoverContent from './../static/popoverContent';

import styles from "./inputPopoverWrapper.module.scss"

const CssPopover = withStyles({
  root: {
    '& .MuiPaper-root': {
      borderRadius: 0
    }
  }
})(Popover)

const InputPopoverWrapper = props => {

  const [anchorEl, setAnchorEl] = React.useState(null);

  const handleClick = event => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const open = Boolean(anchorEl);
  const id = open ? 'simple-popover' : undefined;

  return (
    <div className={styles.inputPopoverWrapper}>
      {props.children}
      <div className={styles.container_PopoverButton}>
        <PopoverButton aria-describedby={id} variant="contained" color="primary" onClick={handleClick} />
      </div>

      <CssPopover
        id={id}
        open={open}
        anchorEl={anchorEl}
        onClose={handleClose}
        anchorOrigin={{
          vertical: 'top',
          horizontal: 'right',
        }}
        transformOrigin={{
          vertical: 'bottom',
          horizontal: 'right',
        }}
      >
        <PopoverContent>{props.content}</PopoverContent>
        <div className={styles.container_closePopoverButton} onClick={handleClose}>
          <Icon name="close" />
        </div>
      </CssPopover>
    </div>
  )
}

export default React.memo(InputPopoverWrapper)