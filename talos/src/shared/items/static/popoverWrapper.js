import React from 'react'
import Popover from '@material-ui/core/Popover';
import { withStyles } from '@material-ui/core/styles';

import PopoverButton from './../controls/popoverButton';
import Icon from './icon';
import PopoverContent from './popoverContent';

import styles from "./popoverWrapper.module.scss"

const CssPopover = withStyles({
  root: {
    '& .MuiPaper-root': {
      borderRadius: 0
    }
  }
})(Popover)

const PopoverWrapper = props => {

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
    <div className={styles.popoverWrapper}>
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

export default React.memo(PopoverWrapper)