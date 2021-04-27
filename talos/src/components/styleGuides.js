import React from 'react';

import FirstTitleExtra from "./../shared/items/static/firstTitleExtra"
import FirstTitle from "./../shared/items/static/firstTitle"
import SecondTitleBold from "./../shared/items/static/secondTitleBold"
import SecondTitle from "./../shared/items/static/secondTitle"
import ThirdTitle from "./../shared/items/static/thirdTitle"
import FourTitle from "./../shared/items/static/fourTitle"
import Paragraph from "./../shared/items/static/paragraph"
import ParagraphSmall from "./../shared/items/static/paragraphSmall"
import ButtonText from "../shared/items/controls/buttonText"
import PrevButton from "./../shared/items/static/prevButton"
import ButtonFill from "../shared/items/controls/buttonFill"
import ButtonFillDafault from "../shared/items/controls/buttonFillDefault"
import NextButton from "./../shared/items/controls/nextButton"
import SwitcherWrapper from "./../shared/items/controls/switcherWrapper"
import InputLabel from "./../shared/items/static/inputLabel"
import InputWrapper from "./../shared/items/controls/inputWrapper"
import InputPopoverWrapper from "./../shared/items/controls/inputPopoverWrapper"
import SliderWrapper from "./../shared/items/controls/sliderWrapper"
import PopoverWrapper from "./../shared/items/static/popoverWrapper"
import CounterWrapper from "./../components/banManagement/counterWrapper"
import TokenInputWrapper from "./../shared/items/controls/tokenInputWrapper"

const StyleGuides = () => {
  return (
    <div style={{ maxWidth: "1030px", margin: "0 auto", padding: "100px 30px", paddingTop: "100vh" }}>
      <div style={{ marginTop: "48px" }}>
        <FirstTitleExtra>56px/60px, Welcome to the AGORA Full Node Client</FirstTitleExtra>
      </div>
      <div style={{ marginTop: "48px" }}>
        <FirstTitle>48px/56px, Ut enim ad minim veniam, quis nostrud exercitation ullamco poriti laboris nisi ut aliquip.</FirstTitle>
      </div>
      <div style={{ marginTop: "48px" }}>
        <SecondTitleBold>36px/48px, This client will allow you to…..The following steps will guide you though….. incididunt ut ero labore et dolore magna aliqua.</SecondTitleBold>
      </div>
      <div style={{ marginTop: "48px" }}>
        <SecondTitle>36px/48px, This client will allow you to…..The following steps will guide you though….. incididunt ut ero labore et dolore magna aliqua.</SecondTitle>
      </div>
      <div style={{ marginTop: "48px" }}>
        <ThirdTitle>28px/32px, Ut enim ad minim veniam, quis nostrud exercitation ullamco poriti laboris nisi ut aliquip ex ea commodo consequat.</ThirdTitle>
      </div>
      <div style={{ marginTop: "48px" }}>
        <FourTitle>20px/30px, Ut enim ad minim veniam, quis nostrud exercitation ullamco poriti laboris nisi ut aliquip ex ea commodo consequat.</FourTitle>
      </div>
      <div style={{ marginTop: "48px" }}>
        <Paragraph>20px/30px, Ut enim ad minim veniam, quis nostrud exercitation ullamco poriti laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in uienply voluptate velit esse cillum dolore eu fugiat nulla pariatur.</Paragraph>
      </div>
      <div style={{ marginTop: "48px" }}>
        <ParagraphSmall>20px/30px, Ut enim ad minim veniam, quis nostrud exercitation ullamco poriti laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in uienply voluptate velit esse cillum dolore eu fugiat nulla pariatur.</ParagraphSmall>
      </div>
      <div style={{ marginTop: "48px" }}>
        <ButtonText>
          <PrevButton>Previous</PrevButton>
        </ButtonText>
      </div>
      <div style={{ marginTop: "48px" }}>
        <ButtonFill>
          <NextButton>Next step</NextButton>
        </ButtonFill>
      </div>
      <div style={{ marginTop: "48px" }}>
        <ButtonFillDafault>
          <NextButton>Continue</NextButton>
        </ButtonFillDafault>
      </div>
      <div style={{ marginTop: "48px" }}>
        <SwitcherWrapper />
      </div>
      <div style={{ marginTop: "48px" }}>
        <InputWrapper id="secretKey" label="Enter Secret Seed here" />
      </div>
      <div style={{ marginTop: "48px" }}>
        <InputWrapper id="secretKey" label="Enter Secret Seed here" disabled />
      </div>
      <div style={{ marginTop: "48px" }}>
        <InputWrapper id="secretKey" label="Enter Secret Seed here" error helperText="The field is incorrect" />
      </div>
      <div style={{ marginTop: "48px" }}>
        <InputPopoverWrapper content="When the network first starts, we need to connect to some peers to learn the topology and find a safe intersection to listen to, and, if we are a validator, to insert ourselves. ">
          <InputWrapper id="secretKey" label="Enter Secret Seed here" />
        </InputPopoverWrapper>
      </div>
      <div style={{ marginTop: "48px" }}>
        <PopoverWrapper content="When the network first starts, we need to connect to some peers to learn the topology and find a safe intersection to listen to, and, if we are a validator, to insert ourselves. " />
      </div>
      <div style={{ marginTop: "48px" }}>
        <InputLabel>Max Failed Requests intil an address is banned</InputLabel>
        <CounterWrapper
          min={1}
          max={10}
          name="maxRequests"
        />
      </div>
      <div style={{ marginTop: "48px" }}>
        <InputLabel>Ban Duration, ms</InputLabel>
        <SliderWrapper
          min={10000}
          max={126000}
          step={100}
          name="duration"
        />
      </div>
      <div style={{ marginTop: "48px" }}>
        <TokenInputWrapper
          name="dns"
          label="DNS"
          onChange={() => { }}
          initAction={() => { }}
          valueStore={{}}
        />
      </div>
    </div>
  )
}

export default StyleGuides;
