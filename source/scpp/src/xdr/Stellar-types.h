// -*- C++ -*-
// Automatically generated from xdr/Stellar-types.x.
// DO NOT EDIT or your changes may be overwritten

#ifndef __XDR_XDR_STELLAR_TYPES_H_INCLUDED__
#define __XDR_XDR_STELLAR_TYPES_H_INCLUDED__ 1

#include <xdrpp/types.h>

namespace stellar {

using Hash = xdr::opaque_array<32>;
using uint256 = xdr::opaque_array<32>;
using uint32 = std::uint32_t;
using int32 = std::int32_t;
using uint64 = std::uint64_t;
using int64 = std::int64_t;

enum CryptoKeyType : std::int32_t {
  KEY_TYPE_ED25519 = 0,
  KEY_TYPE_PRE_AUTH_TX = 1,
  KEY_TYPE_HASH_X = 2,
};
} namespace xdr {
template<> struct xdr_traits<::stellar::CryptoKeyType>
  : xdr_integral_base<::stellar::CryptoKeyType, std::uint32_t> {
  using case_type = std::int32_t;
  static Constexpr const bool is_enum = true;
  static Constexpr const bool is_numeric = false;
  static const char *enum_name(::stellar::CryptoKeyType val) {
    switch (val) {
    case ::stellar::KEY_TYPE_ED25519:
      return "KEY_TYPE_ED25519";
    case ::stellar::KEY_TYPE_PRE_AUTH_TX:
      return "KEY_TYPE_PRE_AUTH_TX";
    case ::stellar::KEY_TYPE_HASH_X:
      return "KEY_TYPE_HASH_X";
    default:
      return nullptr;
    }
  }
  static const std::vector<int32_t> &enum_values() {
    static const std::vector<int32_t> _xdr_enum_vec = {
      ::stellar::KEY_TYPE_ED25519,
      ::stellar::KEY_TYPE_PRE_AUTH_TX,
      ::stellar::KEY_TYPE_HASH_X
    };
    return _xdr_enum_vec;
  }
};
} namespace stellar {

enum PublicKeyType : std::int32_t {
  PUBLIC_KEY_TYPE_ED25519 = KEY_TYPE_ED25519,
};
} namespace xdr {
template<> struct xdr_traits<::stellar::PublicKeyType>
  : xdr_integral_base<::stellar::PublicKeyType, std::uint32_t> {
  using case_type = std::int32_t;
  static Constexpr const bool is_enum = true;
  static Constexpr const bool is_numeric = false;
  static const char *enum_name(::stellar::PublicKeyType val) {
    switch (val) {
    case ::stellar::PUBLIC_KEY_TYPE_ED25519:
      return "PUBLIC_KEY_TYPE_ED25519";
    default:
      return nullptr;
    }
  }
  static const std::vector<int32_t> &enum_values() {
    static const std::vector<int32_t> _xdr_enum_vec = {
      ::stellar::PUBLIC_KEY_TYPE_ED25519
    };
    return _xdr_enum_vec;
  }
};
} namespace stellar {

enum SignerKeyType : std::int32_t {
  SIGNER_KEY_TYPE_ED25519 = KEY_TYPE_ED25519,
  SIGNER_KEY_TYPE_PRE_AUTH_TX = KEY_TYPE_PRE_AUTH_TX,
  SIGNER_KEY_TYPE_HASH_X = KEY_TYPE_HASH_X,
};
} namespace xdr {
template<> struct xdr_traits<::stellar::SignerKeyType>
  : xdr_integral_base<::stellar::SignerKeyType, std::uint32_t> {
  using case_type = std::int32_t;
  static Constexpr const bool is_enum = true;
  static Constexpr const bool is_numeric = false;
  static const char *enum_name(::stellar::SignerKeyType val) {
    switch (val) {
    case ::stellar::SIGNER_KEY_TYPE_ED25519:
      return "SIGNER_KEY_TYPE_ED25519";
    case ::stellar::SIGNER_KEY_TYPE_PRE_AUTH_TX:
      return "SIGNER_KEY_TYPE_PRE_AUTH_TX";
    case ::stellar::SIGNER_KEY_TYPE_HASH_X:
      return "SIGNER_KEY_TYPE_HASH_X";
    default:
      return nullptr;
    }
  }
  static const std::vector<int32_t> &enum_values() {
    static const std::vector<int32_t> _xdr_enum_vec = {
      ::stellar::SIGNER_KEY_TYPE_ED25519,
      ::stellar::SIGNER_KEY_TYPE_PRE_AUTH_TX,
      ::stellar::SIGNER_KEY_TYPE_HASH_X
    };
    return _xdr_enum_vec;
  }
};
} namespace stellar {

struct PublicKey {
  using _xdr_case_type = xdr::xdr_traits<PublicKeyType>::case_type;
private:
  _xdr_case_type type_;
  union {
    uint256 ed25519_;
  };

public:
  static Constexpr const bool _xdr_has_default_case = false;
  static const std::vector<PublicKeyType> &_xdr_case_values() {
    static const std::vector<PublicKeyType> _xdr_disc_vec {
      PUBLIC_KEY_TYPE_ED25519
    };
    return _xdr_disc_vec;
  }
  static Constexpr int _xdr_field_number(_xdr_case_type which) {
    return which == PUBLIC_KEY_TYPE_ED25519 ? 1
      : -1;
  }
  template<typename _F, typename..._A> static bool
  _xdr_with_mem_ptr(_F &_f, _xdr_case_type _which, _A&&..._a) {
    switch (_which) {
    case PUBLIC_KEY_TYPE_ED25519:
      _f(&PublicKey::ed25519_, std::forward<_A>(_a)...);
      return true;
    }
    return false;
  }

  _xdr_case_type _xdr_discriminant() const { return type_; }
  void _xdr_discriminant(_xdr_case_type which, bool validate = true) {
    int fnum = _xdr_field_number(which);
    if (fnum < 0 && validate)
      throw xdr::xdr_bad_discriminant("bad value of type in PublicKey");
    if (fnum != _xdr_field_number(type_)) {
      this->~PublicKey();
      type_ = which;
      _xdr_with_mem_ptr(xdr::field_constructor, type_, *this);
    }
    else
      type_ = which;
  }
  explicit PublicKey(PublicKeyType which = PublicKeyType{}) : type_(which) {
    _xdr_with_mem_ptr(xdr::field_constructor, type_, *this);
  }
  PublicKey(const PublicKey &source) : type_(source.type_) {
    _xdr_with_mem_ptr(xdr::field_constructor, type_, *this, source);
  }
  PublicKey(PublicKey &&source) : type_(source.type_) {
    _xdr_with_mem_ptr(xdr::field_constructor, type_, *this,
                      std::move(source));
  }
  ~PublicKey() { _xdr_with_mem_ptr(xdr::field_destructor, type_, *this); }
  PublicKey &operator=(const PublicKey &source) {
    if (_xdr_field_number(type_)
        == _xdr_field_number(source.type_))
      _xdr_with_mem_ptr(xdr::field_assigner, type_, *this, source);
    else {
      this->~PublicKey();
      type_ = std::numeric_limits<_xdr_case_type>::max();
      _xdr_with_mem_ptr(xdr::field_constructor, source.type_, *this, source);
    }
    type_ = source.type_;
    return *this;
  }
  PublicKey &operator=(PublicKey &&source) {
    if (_xdr_field_number(type_)
         == _xdr_field_number(source.type_))
      _xdr_with_mem_ptr(xdr::field_assigner, type_, *this,
                        std::move(source));
    else {
      this->~PublicKey();
      type_ = std::numeric_limits<_xdr_case_type>::max();
      _xdr_with_mem_ptr(xdr::field_constructor, source.type_, *this,
                        std::move(source));
    }
    type_ = source.type_;
    return *this;
  }

  PublicKeyType type() const { return PublicKeyType(type_); }
  PublicKey &type(PublicKeyType _xdr_d, bool _xdr_validate = true) {
    _xdr_discriminant(_xdr_d, _xdr_validate);
    return *this;
  }

  uint256 &ed25519() {
    if (_xdr_field_number(type_) == 1)
      return ed25519_;
    throw xdr::xdr_wrong_union("PublicKey: ed25519 accessed when not selected");
  }
  const uint256 &ed25519() const {
    if (_xdr_field_number(type_) == 1)
      return ed25519_;
    throw xdr::xdr_wrong_union("PublicKey: ed25519 accessed when not selected");
  }
};
} namespace xdr {
template<> struct xdr_traits<::stellar::PublicKey> : xdr_traits_base {
  static Constexpr const bool is_class = true;
  static Constexpr const bool is_union = true;
  static Constexpr const bool has_fixed_size = false;

  using union_type = ::stellar::PublicKey;
  using case_type = ::stellar::PublicKey::_xdr_case_type;
  using discriminant_type = decltype(std::declval<union_type>().type());

  static const char *union_field_name(case_type which) {
    switch (union_type::_xdr_field_number(which)) {
    case 1:
      return "ed25519";
    }
    return nullptr;
  }
  static const char *union_field_name(const union_type &u) {
    return union_field_name(u._xdr_discriminant());
  }

  static std::size_t serial_size(const ::stellar::PublicKey &obj) {
    std::size_t size = 0;
    if (!obj._xdr_with_mem_ptr(field_size, obj._xdr_discriminant(), obj, size))
      throw xdr_bad_discriminant("bad value of type in PublicKey");
    return size + 4;
  }
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::PublicKey &obj) {
    xdr::archive(ar, obj.type(), "type");
    if (!obj._xdr_with_mem_ptr(field_archiver, obj.type(), ar, obj,
                               union_field_name(obj)))
      throw xdr_bad_discriminant("bad value of type in PublicKey");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::PublicKey &obj) {
    discriminant_type which;
    xdr::archive(ar, which, "type");
    obj.type(which);
    obj._xdr_with_mem_ptr(field_archiver, obj.type(), ar, obj,
                          union_field_name(which));
    xdr::validate(obj);
  }
};
} namespace stellar {

struct SignerKey {
  using _xdr_case_type = xdr::xdr_traits<SignerKeyType>::case_type;
private:
  _xdr_case_type type_;
  union {
    uint256 ed25519_;
    uint256 preAuthTx_;
    uint256 hashX_;
  };

public:
  static Constexpr const bool _xdr_has_default_case = false;
  static const std::vector<SignerKeyType> &_xdr_case_values() {
    static const std::vector<SignerKeyType> _xdr_disc_vec {
      SIGNER_KEY_TYPE_ED25519,
      SIGNER_KEY_TYPE_PRE_AUTH_TX,
      SIGNER_KEY_TYPE_HASH_X
    };
    return _xdr_disc_vec;
  }
  static Constexpr int _xdr_field_number(_xdr_case_type which) {
    return which == SIGNER_KEY_TYPE_ED25519 ? 1
      : which == SIGNER_KEY_TYPE_PRE_AUTH_TX ? 2
      : which == SIGNER_KEY_TYPE_HASH_X ? 3
      : -1;
  }
  template<typename _F, typename..._A> static bool
  _xdr_with_mem_ptr(_F &_f, _xdr_case_type _which, _A&&..._a) {
    switch (_which) {
    case SIGNER_KEY_TYPE_ED25519:
      _f(&SignerKey::ed25519_, std::forward<_A>(_a)...);
      return true;
    case SIGNER_KEY_TYPE_PRE_AUTH_TX:
      _f(&SignerKey::preAuthTx_, std::forward<_A>(_a)...);
      return true;
    case SIGNER_KEY_TYPE_HASH_X:
      _f(&SignerKey::hashX_, std::forward<_A>(_a)...);
      return true;
    }
    return false;
  }

  _xdr_case_type _xdr_discriminant() const { return type_; }
  void _xdr_discriminant(_xdr_case_type which, bool validate = true) {
    int fnum = _xdr_field_number(which);
    if (fnum < 0 && validate)
      throw xdr::xdr_bad_discriminant("bad value of type in SignerKey");
    if (fnum != _xdr_field_number(type_)) {
      this->~SignerKey();
      type_ = which;
      _xdr_with_mem_ptr(xdr::field_constructor, type_, *this);
    }
    else
      type_ = which;
  }
  explicit SignerKey(SignerKeyType which = SignerKeyType{}) : type_(which) {
    _xdr_with_mem_ptr(xdr::field_constructor, type_, *this);
  }
  SignerKey(const SignerKey &source) : type_(source.type_) {
    _xdr_with_mem_ptr(xdr::field_constructor, type_, *this, source);
  }
  SignerKey(SignerKey &&source) : type_(source.type_) {
    _xdr_with_mem_ptr(xdr::field_constructor, type_, *this,
                      std::move(source));
  }
  ~SignerKey() { _xdr_with_mem_ptr(xdr::field_destructor, type_, *this); }
  SignerKey &operator=(const SignerKey &source) {
    if (_xdr_field_number(type_)
        == _xdr_field_number(source.type_))
      _xdr_with_mem_ptr(xdr::field_assigner, type_, *this, source);
    else {
      this->~SignerKey();
      type_ = std::numeric_limits<_xdr_case_type>::max();
      _xdr_with_mem_ptr(xdr::field_constructor, source.type_, *this, source);
    }
    type_ = source.type_;
    return *this;
  }
  SignerKey &operator=(SignerKey &&source) {
    if (_xdr_field_number(type_)
         == _xdr_field_number(source.type_))
      _xdr_with_mem_ptr(xdr::field_assigner, type_, *this,
                        std::move(source));
    else {
      this->~SignerKey();
      type_ = std::numeric_limits<_xdr_case_type>::max();
      _xdr_with_mem_ptr(xdr::field_constructor, source.type_, *this,
                        std::move(source));
    }
    type_ = source.type_;
    return *this;
  }

  SignerKeyType type() const { return SignerKeyType(type_); }
  SignerKey &type(SignerKeyType _xdr_d, bool _xdr_validate = true) {
    _xdr_discriminant(_xdr_d, _xdr_validate);
    return *this;
  }

  uint256 &ed25519() {
    if (_xdr_field_number(type_) == 1)
      return ed25519_;
    throw xdr::xdr_wrong_union("SignerKey: ed25519 accessed when not selected");
  }
  const uint256 &ed25519() const {
    if (_xdr_field_number(type_) == 1)
      return ed25519_;
    throw xdr::xdr_wrong_union("SignerKey: ed25519 accessed when not selected");
  }
  uint256 &preAuthTx() {
    if (_xdr_field_number(type_) == 2)
      return preAuthTx_;
    throw xdr::xdr_wrong_union("SignerKey: preAuthTx accessed when not selected");
  }
  const uint256 &preAuthTx() const {
    if (_xdr_field_number(type_) == 2)
      return preAuthTx_;
    throw xdr::xdr_wrong_union("SignerKey: preAuthTx accessed when not selected");
  }
  uint256 &hashX() {
    if (_xdr_field_number(type_) == 3)
      return hashX_;
    throw xdr::xdr_wrong_union("SignerKey: hashX accessed when not selected");
  }
  const uint256 &hashX() const {
    if (_xdr_field_number(type_) == 3)
      return hashX_;
    throw xdr::xdr_wrong_union("SignerKey: hashX accessed when not selected");
  }
};
} namespace xdr {
template<> struct xdr_traits<::stellar::SignerKey> : xdr_traits_base {
  static Constexpr const bool is_class = true;
  static Constexpr const bool is_union = true;
  static Constexpr const bool has_fixed_size = false;

  using union_type = ::stellar::SignerKey;
  using case_type = ::stellar::SignerKey::_xdr_case_type;
  using discriminant_type = decltype(std::declval<union_type>().type());

  static const char *union_field_name(case_type which) {
    switch (union_type::_xdr_field_number(which)) {
    case 1:
      return "ed25519";
    case 2:
      return "preAuthTx";
    case 3:
      return "hashX";
    }
    return nullptr;
  }
  static const char *union_field_name(const union_type &u) {
    return union_field_name(u._xdr_discriminant());
  }

  static std::size_t serial_size(const ::stellar::SignerKey &obj) {
    std::size_t size = 0;
    if (!obj._xdr_with_mem_ptr(field_size, obj._xdr_discriminant(), obj, size))
      throw xdr_bad_discriminant("bad value of type in SignerKey");
    return size + 4;
  }
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SignerKey &obj) {
    xdr::archive(ar, obj.type(), "type");
    if (!obj._xdr_with_mem_ptr(field_archiver, obj.type(), ar, obj,
                               union_field_name(obj)))
      throw xdr_bad_discriminant("bad value of type in SignerKey");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SignerKey &obj) {
    discriminant_type which;
    xdr::archive(ar, which, "type");
    obj.type(which);
    obj._xdr_with_mem_ptr(field_archiver, obj.type(), ar, obj,
                          union_field_name(which));
    xdr::validate(obj);
  }
};
} namespace stellar {

using Signature = xdr::opaque_vec<64>;
using SignatureHint = xdr::opaque_array<4>;
using NodeID = PublicKey;

struct Curve25519Secret {
  xdr::opaque_array<32> key{};

  Curve25519Secret() = default;
  template<typename _key_T,
           typename = typename
           std::enable_if<std::is_constructible<xdr::opaque_array<32>, _key_T>::value
                         >::type>
  explicit Curve25519Secret(_key_T &&_key)
    : key(std::forward<_key_T>(_key)) {}
};
} namespace xdr {
template<> struct xdr_traits<::stellar::Curve25519Secret>
  : xdr_struct_base<field_ptr<::stellar::Curve25519Secret,
                              decltype(::stellar::Curve25519Secret::key),
                              &::stellar::Curve25519Secret::key>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::Curve25519Secret &obj) {
    archive(ar, obj.key, "key");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::Curve25519Secret &obj) {
    archive(ar, obj.key, "key");
    xdr::validate(obj);
  }
};
} namespace stellar {

struct Curve25519Public {
  xdr::opaque_array<32> key{};

  Curve25519Public() = default;
  template<typename _key_T,
           typename = typename
           std::enable_if<std::is_constructible<xdr::opaque_array<32>, _key_T>::value
                         >::type>
  explicit Curve25519Public(_key_T &&_key)
    : key(std::forward<_key_T>(_key)) {}
};
} namespace xdr {
template<> struct xdr_traits<::stellar::Curve25519Public>
  : xdr_struct_base<field_ptr<::stellar::Curve25519Public,
                              decltype(::stellar::Curve25519Public::key),
                              &::stellar::Curve25519Public::key>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::Curve25519Public &obj) {
    archive(ar, obj.key, "key");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::Curve25519Public &obj) {
    archive(ar, obj.key, "key");
    xdr::validate(obj);
  }
};
} namespace stellar {

struct HmacSha256Key {
  xdr::opaque_array<32> key{};

  HmacSha256Key() = default;
  template<typename _key_T,
           typename = typename
           std::enable_if<std::is_constructible<xdr::opaque_array<32>, _key_T>::value
                         >::type>
  explicit HmacSha256Key(_key_T &&_key)
    : key(std::forward<_key_T>(_key)) {}
};
} namespace xdr {
template<> struct xdr_traits<::stellar::HmacSha256Key>
  : xdr_struct_base<field_ptr<::stellar::HmacSha256Key,
                              decltype(::stellar::HmacSha256Key::key),
                              &::stellar::HmacSha256Key::key>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::HmacSha256Key &obj) {
    archive(ar, obj.key, "key");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::HmacSha256Key &obj) {
    archive(ar, obj.key, "key");
    xdr::validate(obj);
  }
};
} namespace stellar {

struct HmacSha256Mac {
  xdr::opaque_array<32> mac{};

  HmacSha256Mac() = default;
  template<typename _mac_T,
           typename = typename
           std::enable_if<std::is_constructible<xdr::opaque_array<32>, _mac_T>::value
                         >::type>
  explicit HmacSha256Mac(_mac_T &&_mac)
    : mac(std::forward<_mac_T>(_mac)) {}
};
} namespace xdr {
template<> struct xdr_traits<::stellar::HmacSha256Mac>
  : xdr_struct_base<field_ptr<::stellar::HmacSha256Mac,
                              decltype(::stellar::HmacSha256Mac::mac),
                              &::stellar::HmacSha256Mac::mac>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::HmacSha256Mac &obj) {
    archive(ar, obj.mac, "mac");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::HmacSha256Mac &obj) {
    archive(ar, obj.mac, "mac");
    xdr::validate(obj);
  }
};
} namespace stellar {

}

#endif // !__XDR_XDR_STELLAR_TYPES_H_INCLUDED__
