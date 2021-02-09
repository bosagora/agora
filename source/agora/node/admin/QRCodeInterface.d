/*******************************************************************************

    Provides QR service interface used by the node's web-based management
    interface

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.admin.QRCodeInterface;

import agora.common.Config;
import agora.common.crypto.Key;
import agora.common.Types;
import agora.consensus.data.PreImageInfo;
import agora.crypto.Hash;
import agora.utils.Log;
import agora.network.Clock;

import barcode;

import vibe.data.json;
import vibe.http.router;

import std.datetime : SysTime, unixTimeToStdTime;
import std.datetime.timezone : UTC;
import std.format;

import core.time : days;

mixin AddLogger!();

/*******************************************************************************

    Implementation of the Agora User's credentials QR services

    A class to provide a login or encryption key to QRs to verify that
    the owner of the validator from outside agora.
    Respond SVG format's QR according to the get requests.
    Contains QR code generator.

*******************************************************************************/

public class QRCodeInterface
{
    /// The keypair of this node
    private const KeyPair key_pair;

    /// Clock instance
    private Clock clock;

    /***************************************************************************

        Constructor

        Params:
            key_pair = the keypair of this node

    ***************************************************************************/

    public this (const KeyPair key_pair, Clock clock)
    {
        this.key_pair = key_pair;
        this.clock = clock;
    }

    /***************************************************************************

        Respond with QR code containing login information.

        Enter the name of the APP where the login information will be
        used as the get query.

        Convert LoginInfo to JSON format and respond with the QR code
        of SVG format.
        All public key cryptography is done on Curve25519.
        The signature of the vectorCard provides verification function in the SDK.
        This LoginInfo has an expiration time.
        It provide a randomly generated temporary private key encoded
        in strings on demand.
        In the future, there is a need to enter a temporary key.

    ***************************************************************************/

    public void loginQRCreate (scope HTTPServerRequest req,
        scope HTTPServerResponse res)
    {
        // The randomly generated temporary KeyPair
        KeyPair temp_kp = KeyPair.random();

        TimePoint current_time = this.clock.networkTime();
        // A 'nonce' used to allow expiring
        current_time += 60 * 60 * 24 * 90; // (default: +90 days)
        SysTime expires_time = SysTime(unixTimeToStdTime(current_time));

        LoginInfo login_info = LoginInfo(
            temp_kp.secret.toString(PrintMode.Clear),
            VoterCard(
                this.key_pair.address,
                temp_kp.address,
                expires_time.toISOExtString()
            )
        );

        login_info.voter_card.signature =
            this.key_pair.secret.sign(hashFull(login_info.voter_card)[]);

        res.headers["Content-Type"] = "image/svg+xml";
        res.headers["Vary"] = "Accept-Encoding";
        res.writeBody(createQRcode(login_info));
    }

    /***************************************************************************

        Respond with QR code containing EncryptionKey.

        Enter the name of the APP & height where the encryptionKey will be used
        as the get query.

    ***************************************************************************/

    public void keyQRCreate (scope HTTPServerRequest req,
        scope HTTPServerResponse res)
    {
        enforceHTTP("app" in req.query && "height" in req.query,
            HTTPStatus.badRequest, "Missing app/height field.");

        auto app = req.query["app"];
        auto height = Height.fromString(req.query["height"]);

        // TODO: PreImage to be released at that height
        // Or it can be pre-released, so it can be `height + PreimageRevealPeriod`
        PreImageInfo pre_image;

        // blake2b hashing
        const Hash key = hashMulti(pre_image, app);

        EncryptionKey encryptionKey = EncryptionKey(
            app,
            height,
            key
        );

        res.headers["Content-Type"] = "image/svg+xml";
        res.headers["Vary"] = "Accept-Encoding";
        res.writeBody(createQRcode(encryptionKey));
    }

    /***************************************************************************

        SVG format QR code generator

        Use barcode library to make QR code of JSON format.
        Convert the data structure to JSON and return the QR code image
        of the SVG format.

        Params:
            t = Type of struct to QR code

        Returns:
            QR code of XML string

    ***************************************************************************/

    private string createQRcode (T)(T t)
        if (is(T == struct))
    {
        auto str = serializeToJsonString(t);

        auto svgDrawer = new BaseBarCodeSvgDrawer;
        svgDrawer.fixSizeMode = true;
        svgDrawer.W = 400;
        svgDrawer.H = 400;

        auto qr = new Qr;
        auto bc = qr.encode(str);
        return(svgDrawer.draw(bc));
    }
}

/*******************************************************************************

    Defines the LoginInfo.

    This includes the user's credentials.
    Includes a temporary private key used to prevent leakage of the
    validator's private key.

*******************************************************************************/

public struct LoginInfo
{
    // The randomly generated temporary private key encoded as string
    public string private_key;

    // The `Voter card`
    public VoterCard voter_card;
}

/*******************************************************************************

    Defines the VoterCard.

    Voter card provided at login stage
    The voter card contains an expiration date set at 90 days
    from the time of creation.
    The signature is signed with the validator's private key

*******************************************************************************/

public struct VoterCard
{
    // Validator that this voter card represents
    public PublicKey validator;

    // Public key of the `private_key` field
    public PublicKey address;

    // A 'nonce' used to allow expiring / replacing credentials
    // In this case, we just use an expiration date in ISO8601
    public string expires;

    // Finally, the signature, made using `validator_address` private key
    // (IOW: the `Validator` private key) on this whole packet.
    public Signature signature;

    /***************************************************************************

        Implements hashing support

        Params:
            dg = hashing function

    ***************************************************************************/

    public void computeHash (scope HashDg dg) const nothrow @safe @nogc
    {
        hashPart(this.validator, dg);
        hashPart(this.address, dg);
        hashPart(this.expires, dg);
    }
}

/*******************************************************************************

    Defines the EncryptionKey.

    Define an app-specific unique encryption key by app.
    The encryption key is hashed using the blake2 cryptographic hash function.
    The encryption key is derived from the pre-image as follows:
    Hash(pre_image, "APPNAME");

*******************************************************************************/

public struct EncryptionKey
{
    // The app name
    public string app;

    // The block height
    public Height height;

    // Encryption key
    public Hash value;
}

unittest
{
    struct S { int a = 1; }
    S x;
    const KeyPair kp = KeyPair.random();
    auto clock = new Clock(null, null);
    auto qRCodeInterface = new QRCodeInterface(kp, clock);
    string qr_svg = qRCodeInterface.createQRcode(x);
    string sample_svg =
`<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 500 500">
    <rect width="100%" height="100%" fill="#FFFFFF" stroke-width="0"/>
    <path d="M50,50h133.333v19.0476h-133.333z M316.667,50h133.333v19.0476h-133.333z M50,69.0476h19.0476v19.0476h-19.0476z M164.286,69.0476h19.0476v19.0476h-19.0476z M278.571,69.0476h19.0476v19.0476h-19.0476z M316.667,69.0476h19.0476v19.0476h-19.0476z M430.952,69.0476h19.0476v19.0476h-19.0476z M50,88.0952h19.0476v19.0476h-19.0476z M88.0952,88.0952h57.1429v19.0476h-57.1429z M164.286,88.0952h19.0476v19.0476h-19.0476z M221.429,88.0952h38.0952v19.0476h-38.0952z M316.667,88.0952h19.0476v19.0476h-19.0476z M354.762,88.0952h57.1429v19.0476h-57.1429z M430.952,88.0952h19.0476v19.0476h-19.0476z M50,107.143h19.0476v19.0476h-19.0476z M88.0952,107.143h57.1429v19.0476h-57.1429z M164.286,107.143h19.0476v19.0476h-19.0476z M221.429,107.143h38.0952v19.0476h-38.0952z M278.571,107.143h19.0476v19.0476h-19.0476z M316.667,107.143h19.0476v19.0476h-19.0476z M354.762,107.143h57.1429v19.0476h-57.1429z M430.952,107.143h19.0476v19.0476h-19.0476z M50,126.19h19.0476v19.0476h-19.0476z M88.0952,126.19h57.1429v19.0476h-57.1429z M164.286,126.19h19.0476v19.0476h-19.0476z M202.381,126.19h57.1429v19.0476h-57.1429z M278.571,126.19h19.0476v19.0476h-19.0476z M316.667,126.19h19.0476v19.0476h-19.0476z M354.762,126.19h57.1429v19.0476h-57.1429z M430.952,126.19h19.0476v19.0476h-19.0476z M50,145.238h19.0476v19.0476h-19.0476z M164.286,145.238h19.0476v19.0476h-19.0476z M221.429,145.238h19.0476v19.0476h-19.0476z M259.524,145.238h38.0952v19.0476h-38.0952z M316.667,145.238h19.0476v19.0476h-19.0476z M430.952,145.238h19.0476v19.0476h-19.0476z M50,164.286h133.333v19.0476h-133.333z M202.381,164.286h19.0476v19.0476h-19.0476z M240.476,164.286h19.0476v19.0476h-19.0476z M278.571,164.286h19.0476v19.0476h-19.0476z M316.667,164.286h133.333v19.0476h-133.333z M202.381,183.333h38.0952v19.0476h-38.0952z M88.0952,202.381h38.0952v19.0476h-38.0952z M164.286,202.381h76.1905v19.0476h-76.1905z M297.619,202.381h38.0952v19.0476h-38.0952z M354.762,202.381h19.0476v19.0476h-19.0476z M88.0952,221.429h19.0476v19.0476h-19.0476z M126.19,221.429h19.0476v19.0476h-19.0476z M183.333,221.429h38.0952v19.0476h-38.0952z M335.714,221.429h19.0476v19.0476h-19.0476z M392.857,221.429h19.0476v19.0476h-19.0476z M430.952,221.429h19.0476v19.0476h-19.0476z M107.143,240.476h38.0952v19.0476h-38.0952z M164.286,240.476h19.0476v19.0476h-19.0476z M202.381,240.476h38.0952v19.0476h-38.0952z M259.524,240.476h19.0476v19.0476h-19.0476z M297.619,240.476h19.0476v19.0476h-19.0476z M373.81,240.476h38.0952v19.0476h-38.0952z M430.952,240.476h19.0476v19.0476h-19.0476z M69.0476,259.524h19.0476v19.0476h-19.0476z M126.19,259.524h38.0952v19.0476h-38.0952z M183.333,259.524h19.0476v19.0476h-19.0476z M221.429,259.524h57.1429v19.0476h-57.1429z M297.619,259.524h19.0476v19.0476h-19.0476z M335.714,259.524h57.1429v19.0476h-57.1429z M430.952,259.524h19.0476v19.0476h-19.0476z M50,278.571h76.1905v19.0476h-76.1905z M164.286,278.571h19.0476v19.0476h-19.0476z M221.429,278.571h19.0476v19.0476h-19.0476z M259.524,278.571h19.0476v19.0476h-19.0476z M354.762,278.571h19.0476v19.0476h-19.0476z M430.952,278.571h19.0476v19.0476h-19.0476z M202.381,297.619h19.0476v19.0476h-19.0476z M240.476,297.619h19.0476v19.0476h-19.0476z M297.619,297.619h19.0476v19.0476h-19.0476z M335.714,297.619h57.1429v19.0476h-57.1429z M411.905,297.619h19.0476v19.0476h-19.0476z M50,316.667h133.333v19.0476h-133.333z M202.381,316.667h19.0476v19.0476h-19.0476z M297.619,316.667h95.2381v19.0476h-95.2381z M50,335.714h19.0476v19.0476h-19.0476z M164.286,335.714h19.0476v19.0476h-19.0476z M221.429,335.714h19.0476v19.0476h-19.0476z M259.524,335.714h19.0476v19.0476h-19.0476z M392.857,335.714h57.1429v19.0476h-57.1429z M50,354.762h19.0476v19.0476h-19.0476z M88.0952,354.762h57.1429v19.0476h-57.1429z M164.286,354.762h19.0476v19.0476h-19.0476z M221.429,354.762h114.286v19.0476h-114.286z M373.81,354.762h76.1905v19.0476h-76.1905z M50,373.81h19.0476v19.0476h-19.0476z M88.0952,373.81h57.1429v19.0476h-57.1429z M164.286,373.81h19.0476v19.0476h-19.0476z M202.381,373.81h19.0476v19.0476h-19.0476z M259.524,373.81h38.0952v19.0476h-38.0952z M316.667,373.81h38.0952v19.0476h-38.0952z M411.905,373.81h19.0476v19.0476h-19.0476z M50,392.857h19.0476v19.0476h-19.0476z M88.0952,392.857h57.1429v19.0476h-57.1429z M164.286,392.857h19.0476v19.0476h-19.0476z M202.381,392.857h19.0476v19.0476h-19.0476z M240.476,392.857h76.1905v19.0476h-76.1905z M335.714,392.857h19.0476v19.0476h-19.0476z M50,411.905h19.0476v19.0476h-19.0476z M164.286,411.905h19.0476v19.0476h-19.0476z M240.476,411.905h38.0952v19.0476h-38.0952z M354.762,411.905h38.0952v19.0476h-38.0952z M430.952,411.905h19.0476v19.0476h-19.0476z M50,430.952h133.333v19.0476h-133.333z M240.476,430.952h19.0476v19.0476h-19.0476z M297.619,430.952h38.0952v19.0476h-38.0952z M373.81,430.952h38.0952v19.0476h-38.0952z" fill="#000000" stroke-width="0"/>
</svg>`;
    assert(qr_svg == sample_svg);
}
