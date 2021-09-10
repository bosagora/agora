import React from "react";
import List from "@material-ui/core/List";
import ListItem from "@material-ui/core/ListItem";
import Collapse from "@material-ui/core/Collapse";
import { NavLink, Redirect } from "react-router-dom";
import styles from "./menu.module.scss";
import { logout } from "../../actions/loginAction";
import { connect } from "react-redux";
import PropTypes from "prop-types";
import { ExpandLess, ExpandMore } from "@material-ui/icons";
import {ListItemText} from "@material-ui/core";


const Menu = (props) => {
  const menuStatus = {
    integration:true,
    system:true,
  };

  const [menuControls, setMenuControls] = React.useState(menuStatus);
  const { isLoggedIn, logout } = props;

  const groupClickhandle = (name) => {
    setMenuControls({...menuStatus , [name]:!menuControls[name]});
  };

  return isLoggedIn ? (
    <List component="nav" aria-labelledby="nested-list-subheader"
      className={(styles.root)}>
      <ListItem className={styles.outer} onClick={()=>groupClickhandle("integration")}>
        <NavLink className={styles.naviLink} to="/admin">
          App Integration
        </NavLink>
        {menuControls.integration ? <ExpandLess /> : <ExpandMore />}
      </ListItem>
      <Collapse in={menuControls.integration} timeout="auto" unmountOnExit>
        <List component="div" disablePadding>
          <ListItem button className={styles.nested} button component={NavLink}  to="/admin/validator">
              Validator Authentication
          </ListItem>
          <ListItem button className={styles.nested} button component={NavLink} to="/admin/encryption">
              Encryption Key
          </ListItem>
        </List>
      </Collapse>

      <ListItem button className={styles.outer} onClick={()=>groupClickhandle("system")} >
          <ListItemText primary="System" />
          {menuControls.system ? <ExpandLess /> : <ExpandMore />}
      </ListItem>
      <Collapse in={menuControls.system}   timeout="auto" unmountOnExit>
        <List component="div" disablePadding>
          <ListItem button className={styles.nested} onClick={logout}>
            Logout
          </ListItem>
        </List>
      </Collapse>

    </List>
  ) : (
    <Redirect to="/" />
  );
};
Menu.propTypes = {
  isLoggedIn: PropTypes.bool,
};
const mapStateToProps = (state) => {
  return {
    isLoggedIn: state.login.isLoggedIn,
  };
};
const mapDispatchToProps = (dispatch) => ({
  logout: () => dispatch(logout()),
});
export default connect(mapStateToProps, mapDispatchToProps)(Menu);
