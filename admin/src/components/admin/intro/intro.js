import React from "react";
import SecondTitleBold from "../../common/static/secondTitleBold";
import styles from "./intro.module.scss";
import MenuTitle from "../../common/static/menuTitle";
import PlayArrowIcon from "@material-ui/icons/PlayArrow";
import { Link } from "react-router-dom";

const AdminIntro = (props) => {
  return (
    <div className={styles.introWrapper}>
      <div className={styles.introContent}>
        <SecondTitleBold>Welcome to the Admin Interface</SecondTitleBold>
        <br />
        <p>
          You can select the functions provided here from the left menu. A brief
          description of each function.
        </p>
        <br />
        <br />
      </div>
      <Link className={styles.menuTitleContent} to="/admin/validator">
        <MenuTitle>
          <PlayArrowIcon fontSize="small" /> Valiator Authentication
        </MenuTitle>
        <p>
          Provides QR code with the information required to add the validator
          node with the Votera app.
        </p>
      </Link>
      <Link className={styles.menuTitleContent} to="/admin/encryption">
        <MenuTitle>
          <PlayArrowIcon fontSize="small" /> Encryption Key
        </MenuTitle>
        <p>
          Provides QR code with the information needed to encrypt the ballot.
        </p>
      </Link>
    </div>
  );
};
export default AdminIntro;
