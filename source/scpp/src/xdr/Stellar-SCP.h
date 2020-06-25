// -*- C++ -*-
// Automatically generated from xdr/Stellar-SCP.x.
// DO NOT EDIT or your changes may be overwritten

#ifndef __XDR_XDR_STELLAR_SCP_H_INCLUDED__
#define __XDR_XDR_STELLAR_SCP_H_INCLUDED__ 1

#include <xdrpp/types.h>

#include "xdr/Stellar-types.h"

namespace stellar {

using Value = xdr::opaque_vec<>;

struct SCPBallot {
  uint32 counter{};
  Value value{};

  SCPBallot() = default;
  template<typename _counter_T,
           typename _value_T,
           typename = typename
           std::enable_if<std::is_constructible<uint32, _counter_T>::value
                          && std::is_constructible<Value, _value_T>::value
                         >::type>
  explicit SCPBallot(_counter_T &&_counter,
                     _value_T &&_value)
    : counter(std::forward<_counter_T>(_counter)),
      value(std::forward<_value_T>(_value)) {}
};
} namespace xdr {
template<> struct xdr_traits<::stellar::SCPBallot>
  : xdr_struct_base<field_ptr<::stellar::SCPBallot,
                              decltype(::stellar::SCPBallot::counter),
                              &::stellar::SCPBallot::counter>,
                    field_ptr<::stellar::SCPBallot,
                              decltype(::stellar::SCPBallot::value),
                              &::stellar::SCPBallot::value>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SCPBallot &obj) {
    archive(ar, obj.counter, "counter");
    archive(ar, obj.value, "value");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SCPBallot &obj) {
    archive(ar, obj.counter, "counter");
    archive(ar, obj.value, "value");
    xdr::validate(obj);
  }
};
} namespace stellar {

enum SCPStatementType : std::int32_t {
  SCP_ST_PREPARE = 0,
  SCP_ST_CONFIRM = 1,
  SCP_ST_EXTERNALIZE = 2,
  SCP_ST_NOMINATE = 3,
};
} namespace xdr {
template<> struct xdr_traits<::stellar::SCPStatementType>
  : xdr_integral_base<::stellar::SCPStatementType, std::uint32_t> {
  using case_type = std::int32_t;
  static Constexpr const bool is_enum = true;
  static Constexpr const bool is_numeric = false;
  static const char *enum_name(::stellar::SCPStatementType val) {
    switch (val) {
    case ::stellar::SCP_ST_PREPARE:
      return "SCP_ST_PREPARE";
    case ::stellar::SCP_ST_CONFIRM:
      return "SCP_ST_CONFIRM";
    case ::stellar::SCP_ST_EXTERNALIZE:
      return "SCP_ST_EXTERNALIZE";
    case ::stellar::SCP_ST_NOMINATE:
      return "SCP_ST_NOMINATE";
    default:
      return nullptr;
    }
  }
  static const std::vector<int32_t> &enum_values() {
    static const std::vector<int32_t> _xdr_enum_vec = {
      ::stellar::SCP_ST_PREPARE,
      ::stellar::SCP_ST_CONFIRM,
      ::stellar::SCP_ST_EXTERNALIZE,
      ::stellar::SCP_ST_NOMINATE
    };
    return _xdr_enum_vec;
  }
};
} namespace stellar {

struct SCPNomination {
  xdr::xvector<Value> votes{};
  xdr::xvector<Value> accepted{};

  SCPNomination() = default;
  template<typename _votes_T,
           typename _accepted_T,
           typename = typename
           std::enable_if<std::is_constructible<xdr::xvector<Value>, _votes_T>::value
                          && std::is_constructible<xdr::xvector<Value>, _accepted_T>::value
                         >::type>
  explicit SCPNomination(_votes_T &&_votes,
                         _accepted_T &&_accepted)
    : votes(std::forward<_votes_T>(_votes)),
      accepted(std::forward<_accepted_T>(_accepted)) {}
};
} namespace xdr {
template<> struct xdr_traits<::stellar::SCPNomination>
  : xdr_struct_base<field_ptr<::stellar::SCPNomination,
                              decltype(::stellar::SCPNomination::votes),
                              &::stellar::SCPNomination::votes>,
                    field_ptr<::stellar::SCPNomination,
                              decltype(::stellar::SCPNomination::accepted),
                              &::stellar::SCPNomination::accepted>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SCPNomination &obj) {
    archive(ar, obj.votes, "votes");
    archive(ar, obj.accepted, "accepted");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SCPNomination &obj) {
    archive(ar, obj.votes, "votes");
    archive(ar, obj.accepted, "accepted");
    xdr::validate(obj);
  }
};
} namespace stellar {

struct SCPStatement {
  struct _pledges_t {
    struct _prepare_t {
      SCPBallot ballot{};
      xdr::pointer<SCPBallot> prepared{};
      xdr::pointer<SCPBallot> preparedPrime{};
      uint32 nC{};
      uint32 nH{};

      _prepare_t() = default;
      template<typename _ballot_T,
               typename _prepared_T,
               typename _preparedPrime_T,
               typename _nC_T,
               typename _nH_T,
               typename = typename
               std::enable_if<std::is_constructible<SCPBallot, _ballot_T>::value
                              && std::is_constructible<xdr::pointer<SCPBallot>, _prepared_T>::value
                              && std::is_constructible<xdr::pointer<SCPBallot>, _preparedPrime_T>::value
                              && std::is_constructible<uint32, _nC_T>::value
                              && std::is_constructible<uint32, _nH_T>::value
                             >::type>
      explicit _prepare_t(_ballot_T &&_ballot,
                          _prepared_T &&_prepared,
                          _preparedPrime_T &&_preparedPrime,
                          _nC_T &&_nC,
                          _nH_T &&_nH)
        : ballot(std::forward<_ballot_T>(_ballot)),
          prepared(std::forward<_prepared_T>(_prepared)),
          preparedPrime(std::forward<_preparedPrime_T>(_preparedPrime)),
          nC(std::forward<_nC_T>(_nC)),
          nH(std::forward<_nH_T>(_nH)) {}
    };
    struct _confirm_t {
      SCPBallot ballot{};
      uint32 nPrepared{};
      uint32 nCommit{};
      uint32 nH{};

      _confirm_t() = default;
      template<typename _ballot_T,
               typename _nPrepared_T,
               typename _nCommit_T,
               typename _nH_T,
               typename = typename
               std::enable_if<std::is_constructible<SCPBallot, _ballot_T>::value
                              && std::is_constructible<uint32, _nPrepared_T>::value
                              && std::is_constructible<uint32, _nCommit_T>::value
                              && std::is_constructible<uint32, _nH_T>::value
                             >::type>
      explicit _confirm_t(_ballot_T &&_ballot,
                          _nPrepared_T &&_nPrepared,
                          _nCommit_T &&_nCommit,
                          _nH_T &&_nH)
        : ballot(std::forward<_ballot_T>(_ballot)),
          nPrepared(std::forward<_nPrepared_T>(_nPrepared)),
          nCommit(std::forward<_nCommit_T>(_nCommit)),
          nH(std::forward<_nH_T>(_nH)) {}
    };
    struct _externalize_t {
      SCPBallot commit{};
      uint32 nH{};

      _externalize_t() = default;
      template<typename _commit_T,
               typename _nH_T,
               typename = typename
               std::enable_if<std::is_constructible<SCPBallot, _commit_T>::value
                              && std::is_constructible<uint32, _nH_T>::value
                             >::type>
      explicit _externalize_t(_commit_T &&_commit,
                              _nH_T &&_nH)
        : commit(std::forward<_commit_T>(_commit)),
          nH(std::forward<_nH_T>(_nH)) {}
    };

    using _xdr_case_type = xdr::xdr_traits<SCPStatementType>::case_type;
/*  private:*/  // BPFK note: cannot be private as we require runtime layout checks
    _xdr_case_type type_;
    union {
      _prepare_t prepare_;
      _confirm_t confirm_;
      _externalize_t externalize_;
      SCPNomination nominate_;
    };

  public:
    static Constexpr const bool _xdr_has_default_case = false;
    static const std::vector<SCPStatementType> &_xdr_case_values() {
      static const std::vector<SCPStatementType> _xdr_disc_vec {
        SCP_ST_PREPARE,
        SCP_ST_CONFIRM,
        SCP_ST_EXTERNALIZE,
        SCP_ST_NOMINATE
      };
      return _xdr_disc_vec;
    }
    static Constexpr int _xdr_field_number(_xdr_case_type which) {
      return which == SCP_ST_PREPARE ? 1
        : which == SCP_ST_CONFIRM ? 2
        : which == SCP_ST_EXTERNALIZE ? 3
        : which == SCP_ST_NOMINATE ? 4
        : -1;
    }
    template<typename _F, typename..._A> static bool
    _xdr_with_mem_ptr(_F &_f, _xdr_case_type _which, _A&&..._a) {
      switch (_which) {
      case SCP_ST_PREPARE:
        _f(&_pledges_t::prepare_, std::forward<_A>(_a)...);
        return true;
      case SCP_ST_CONFIRM:
        _f(&_pledges_t::confirm_, std::forward<_A>(_a)...);
        return true;
      case SCP_ST_EXTERNALIZE:
        _f(&_pledges_t::externalize_, std::forward<_A>(_a)...);
        return true;
      case SCP_ST_NOMINATE:
        _f(&_pledges_t::nominate_, std::forward<_A>(_a)...);
        return true;
      }
      return false;
    }

    _xdr_case_type _xdr_discriminant() const { return type_; }
    void _xdr_discriminant(_xdr_case_type which, bool validate = true) {
      int fnum = _xdr_field_number(which);
      if (fnum < 0 && validate)
        throw xdr::xdr_bad_discriminant("bad value of type in _pledges_t");
      if (fnum != _xdr_field_number(type_)) {
        this->~_pledges_t();
        type_ = which;
        _xdr_with_mem_ptr(xdr::field_constructor, type_, *this);
      }
      else
        type_ = which;
    }
    explicit _pledges_t(SCPStatementType which = SCPStatementType{}) : type_(which) {
      _xdr_with_mem_ptr(xdr::field_constructor, type_, *this);
    }
    _pledges_t(const _pledges_t &source) : type_(source.type_) {
      _xdr_with_mem_ptr(xdr::field_constructor, type_, *this, source);
    }
    _pledges_t(_pledges_t &&source) : type_(source.type_) {
      _xdr_with_mem_ptr(xdr::field_constructor, type_, *this,
                        std::move(source));
    }
    ~_pledges_t() { _xdr_with_mem_ptr(xdr::field_destructor, type_, *this); }
    _pledges_t &operator=(const _pledges_t &source) {
      if (_xdr_field_number(type_)
          == _xdr_field_number(source.type_))
        _xdr_with_mem_ptr(xdr::field_assigner, type_, *this, source);
      else {
        this->~_pledges_t();
        type_ = std::numeric_limits<_xdr_case_type>::max();
        _xdr_with_mem_ptr(xdr::field_constructor, source.type_, *this, source);
      }
      type_ = source.type_;
      return *this;
    }
    _pledges_t &operator=(_pledges_t &&source) {
      if (_xdr_field_number(type_)
           == _xdr_field_number(source.type_))
        _xdr_with_mem_ptr(xdr::field_assigner, type_, *this,
                          std::move(source));
      else {
        this->~_pledges_t();
        type_ = std::numeric_limits<_xdr_case_type>::max();
        _xdr_with_mem_ptr(xdr::field_constructor, source.type_, *this,
                          std::move(source));
      }
      type_ = source.type_;
      return *this;
    }

    SCPStatementType type() const { return SCPStatementType(type_); }
    _pledges_t &type(SCPStatementType _xdr_d, bool _xdr_validate = true) {
      _xdr_discriminant(_xdr_d, _xdr_validate);
      return *this;
    }

    _prepare_t &prepare() {
      if (_xdr_field_number(type_) == 1)
        return prepare_;
      throw xdr::xdr_wrong_union("_pledges_t: prepare accessed when not selected");
    }
    const _prepare_t &prepare() const {
      if (_xdr_field_number(type_) == 1)
        return prepare_;
      throw xdr::xdr_wrong_union("_pledges_t: prepare accessed when not selected");
    }
    _confirm_t &confirm() {
      if (_xdr_field_number(type_) == 2)
        return confirm_;
      throw xdr::xdr_wrong_union("_pledges_t: confirm accessed when not selected");
    }
    const _confirm_t &confirm() const {
      if (_xdr_field_number(type_) == 2)
        return confirm_;
      throw xdr::xdr_wrong_union("_pledges_t: confirm accessed when not selected");
    }
    _externalize_t &externalize() {
      if (_xdr_field_number(type_) == 3)
        return externalize_;
      throw xdr::xdr_wrong_union("_pledges_t: externalize accessed when not selected");
    }
    const _externalize_t &externalize() const {
      if (_xdr_field_number(type_) == 3)
        return externalize_;
      throw xdr::xdr_wrong_union("_pledges_t: externalize accessed when not selected");
    }
    SCPNomination &nominate() {
      if (_xdr_field_number(type_) == 4)
        return nominate_;
      throw xdr::xdr_wrong_union("_pledges_t: nominate accessed when not selected");
    }
    const SCPNomination &nominate() const {
      if (_xdr_field_number(type_) == 4)
        return nominate_;
      throw xdr::xdr_wrong_union("_pledges_t: nominate accessed when not selected");
    }
  };

  NodeID nodeID{};
  uint64 slotIndex{};
  _pledges_t pledges{};

  SCPStatement() = default;
  template<typename _nodeID_T,
           typename _slotIndex_T,
           typename _pledges_T,
           typename = typename
           std::enable_if<std::is_constructible<NodeID, _nodeID_T>::value
                          && std::is_constructible<uint64, _slotIndex_T>::value
                          && std::is_constructible<_pledges_t, _pledges_T>::value
                         >::type>
  explicit SCPStatement(_nodeID_T &&_nodeID,
                        _slotIndex_T &&_slotIndex,
                        _pledges_T &&_pledges)
    : nodeID(std::forward<_nodeID_T>(_nodeID)),
      slotIndex(std::forward<_slotIndex_T>(_slotIndex)),
      pledges(std::forward<_pledges_T>(_pledges)) {}
};
} namespace xdr {
template<> struct xdr_traits<::stellar::SCPStatement::_pledges_t::_prepare_t>
  : xdr_struct_base<field_ptr<::stellar::SCPStatement::_pledges_t::_prepare_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_prepare_t::ballot),
                              &::stellar::SCPStatement::_pledges_t::_prepare_t::ballot>,
                    field_ptr<::stellar::SCPStatement::_pledges_t::_prepare_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_prepare_t::prepared),
                              &::stellar::SCPStatement::_pledges_t::_prepare_t::prepared>,
                    field_ptr<::stellar::SCPStatement::_pledges_t::_prepare_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_prepare_t::preparedPrime),
                              &::stellar::SCPStatement::_pledges_t::_prepare_t::preparedPrime>,
                    field_ptr<::stellar::SCPStatement::_pledges_t::_prepare_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_prepare_t::nC),
                              &::stellar::SCPStatement::_pledges_t::_prepare_t::nC>,
                    field_ptr<::stellar::SCPStatement::_pledges_t::_prepare_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_prepare_t::nH),
                              &::stellar::SCPStatement::_pledges_t::_prepare_t::nH>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SCPStatement::_pledges_t::_prepare_t &obj) {
    archive(ar, obj.ballot, "ballot");
    archive(ar, obj.prepared, "prepared");
    archive(ar, obj.preparedPrime, "preparedPrime");
    archive(ar, obj.nC, "nC");
    archive(ar, obj.nH, "nH");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SCPStatement::_pledges_t::_prepare_t &obj) {
    archive(ar, obj.ballot, "ballot");
    archive(ar, obj.prepared, "prepared");
    archive(ar, obj.preparedPrime, "preparedPrime");
    archive(ar, obj.nC, "nC");
    archive(ar, obj.nH, "nH");
    xdr::validate(obj);
  }
};
template<> struct xdr_traits<::stellar::SCPStatement::_pledges_t::_confirm_t>
  : xdr_struct_base<field_ptr<::stellar::SCPStatement::_pledges_t::_confirm_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_confirm_t::ballot),
                              &::stellar::SCPStatement::_pledges_t::_confirm_t::ballot>,
                    field_ptr<::stellar::SCPStatement::_pledges_t::_confirm_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_confirm_t::nPrepared),
                              &::stellar::SCPStatement::_pledges_t::_confirm_t::nPrepared>,
                    field_ptr<::stellar::SCPStatement::_pledges_t::_confirm_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_confirm_t::nCommit),
                              &::stellar::SCPStatement::_pledges_t::_confirm_t::nCommit>,
                    field_ptr<::stellar::SCPStatement::_pledges_t::_confirm_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_confirm_t::nH),
                              &::stellar::SCPStatement::_pledges_t::_confirm_t::nH>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SCPStatement::_pledges_t::_confirm_t &obj) {
    archive(ar, obj.ballot, "ballot");
    archive(ar, obj.nPrepared, "nPrepared");
    archive(ar, obj.nCommit, "nCommit");
    archive(ar, obj.nH, "nH");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SCPStatement::_pledges_t::_confirm_t &obj) {
    archive(ar, obj.ballot, "ballot");
    archive(ar, obj.nPrepared, "nPrepared");
    archive(ar, obj.nCommit, "nCommit");
    archive(ar, obj.nH, "nH");
    xdr::validate(obj);
  }
};
template<> struct xdr_traits<::stellar::SCPStatement::_pledges_t::_externalize_t>
  : xdr_struct_base<field_ptr<::stellar::SCPStatement::_pledges_t::_externalize_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_externalize_t::commit),
                              &::stellar::SCPStatement::_pledges_t::_externalize_t::commit>,
                    field_ptr<::stellar::SCPStatement::_pledges_t::_externalize_t,
                              decltype(::stellar::SCPStatement::_pledges_t::_externalize_t::nH),
                              &::stellar::SCPStatement::_pledges_t::_externalize_t::nH>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SCPStatement::_pledges_t::_externalize_t &obj) {
    archive(ar, obj.commit, "commit");
    archive(ar, obj.nH, "nH");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SCPStatement::_pledges_t::_externalize_t &obj) {
    archive(ar, obj.commit, "commit");
    archive(ar, obj.nH, "nH");
    xdr::validate(obj);
  }
};
template<> struct xdr_traits<::stellar::SCPStatement::_pledges_t> : xdr_traits_base {
  static Constexpr const bool is_class = true;
  static Constexpr const bool is_union = true;
  static Constexpr const bool has_fixed_size = false;

  using union_type = ::stellar::SCPStatement::_pledges_t;
  using case_type = ::stellar::SCPStatement::_pledges_t::_xdr_case_type;
  using discriminant_type = decltype(std::declval<union_type>().type());

  static const char *union_field_name(case_type which) {
    switch (union_type::_xdr_field_number(which)) {
    case 1:
      return "prepare";
    case 2:
      return "confirm";
    case 3:
      return "externalize";
    case 4:
      return "nominate";
    }
    return nullptr;
  }
  static const char *union_field_name(const union_type &u) {
    return union_field_name(u._xdr_discriminant());
  }

  static std::size_t serial_size(const ::stellar::SCPStatement::_pledges_t &obj) {
    std::size_t size = 0;
    if (!obj._xdr_with_mem_ptr(field_size, obj._xdr_discriminant(), obj, size))
      throw xdr_bad_discriminant("bad value of type in _pledges_t");
    return size + 4;
  }
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SCPStatement::_pledges_t &obj) {
    xdr::archive(ar, obj.type(), "type");
    if (!obj._xdr_with_mem_ptr(field_archiver, obj.type(), ar, obj,
                               union_field_name(obj)))
      throw xdr_bad_discriminant("bad value of type in _pledges_t");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SCPStatement::_pledges_t &obj) {
    discriminant_type which;
    xdr::archive(ar, which, "type");
    obj.type(which);
    obj._xdr_with_mem_ptr(field_archiver, obj.type(), ar, obj,
                          union_field_name(which));
    xdr::validate(obj);
  }
};
template<> struct xdr_traits<::stellar::SCPStatement>
  : xdr_struct_base<field_ptr<::stellar::SCPStatement,
                              decltype(::stellar::SCPStatement::nodeID),
                              &::stellar::SCPStatement::nodeID>,
                    field_ptr<::stellar::SCPStatement,
                              decltype(::stellar::SCPStatement::slotIndex),
                              &::stellar::SCPStatement::slotIndex>,
                    field_ptr<::stellar::SCPStatement,
                              decltype(::stellar::SCPStatement::pledges),
                              &::stellar::SCPStatement::pledges>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SCPStatement &obj) {
    archive(ar, obj.nodeID, "nodeID");
    archive(ar, obj.slotIndex, "slotIndex");
    archive(ar, obj.pledges, "pledges");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SCPStatement &obj) {
    archive(ar, obj.nodeID, "nodeID");
    archive(ar, obj.slotIndex, "slotIndex");
    archive(ar, obj.pledges, "pledges");
    xdr::validate(obj);
  }
};
} namespace stellar {

struct SCPEnvelope {
  SCPStatement statement{};
  Signature signature{};

  SCPEnvelope() = default;
  template<typename _statement_T,
           typename _signature_T,
           typename = typename
           std::enable_if<std::is_constructible<SCPStatement, _statement_T>::value
                          && std::is_constructible<Signature, _signature_T>::value
                         >::type>
  explicit SCPEnvelope(_statement_T &&_statement,
                       _signature_T &&_signature)
    : statement(std::forward<_statement_T>(_statement)),
      signature(std::forward<_signature_T>(_signature)) {}
};
} namespace xdr {
template<> struct xdr_traits<::stellar::SCPEnvelope>
  : xdr_struct_base<field_ptr<::stellar::SCPEnvelope,
                              decltype(::stellar::SCPEnvelope::statement),
                              &::stellar::SCPEnvelope::statement>,
                    field_ptr<::stellar::SCPEnvelope,
                              decltype(::stellar::SCPEnvelope::signature),
                              &::stellar::SCPEnvelope::signature>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SCPEnvelope &obj) {
    archive(ar, obj.statement, "statement");
    archive(ar, obj.signature, "signature");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SCPEnvelope &obj) {
    archive(ar, obj.statement, "statement");
    archive(ar, obj.signature, "signature");
    xdr::validate(obj);
  }
};
} namespace stellar {

struct SCPQuorumSet {
  uint32 threshold{};
  xdr::xvector<PublicKey> validators{};
  xdr::xvector<SCPQuorumSet> innerSets{};

  SCPQuorumSet() = default;
  template<typename _threshold_T,
           typename _validators_T,
           typename _innerSets_T,
           typename = typename
           std::enable_if<std::is_constructible<uint32, _threshold_T>::value
                          && std::is_constructible<xdr::xvector<PublicKey>, _validators_T>::value
                          && std::is_constructible<xdr::xvector<SCPQuorumSet>, _innerSets_T>::value
                         >::type>
  explicit SCPQuorumSet(_threshold_T &&_threshold,
                        _validators_T &&_validators,
                        _innerSets_T &&_innerSets)
    : threshold(std::forward<_threshold_T>(_threshold)),
      validators(std::forward<_validators_T>(_validators)),
      innerSets(std::forward<_innerSets_T>(_innerSets)) {}
};
} namespace xdr {
template<> struct xdr_traits<::stellar::SCPQuorumSet>
  : xdr_struct_base<field_ptr<::stellar::SCPQuorumSet,
                              decltype(::stellar::SCPQuorumSet::threshold),
                              &::stellar::SCPQuorumSet::threshold>,
                    field_ptr<::stellar::SCPQuorumSet,
                              decltype(::stellar::SCPQuorumSet::validators),
                              &::stellar::SCPQuorumSet::validators>,
                    field_ptr<::stellar::SCPQuorumSet,
                              decltype(::stellar::SCPQuorumSet::innerSets),
                              &::stellar::SCPQuorumSet::innerSets>> {
  template<typename Archive> static void
  save(Archive &ar, const ::stellar::SCPQuorumSet &obj) {
    archive(ar, obj.threshold, "threshold");
    archive(ar, obj.validators, "validators");
    archive(ar, obj.innerSets, "innerSets");
  }
  template<typename Archive> static void
  load(Archive &ar, ::stellar::SCPQuorumSet &obj) {
    archive(ar, obj.threshold, "threshold");
    archive(ar, obj.validators, "validators");
    archive(ar, obj.innerSets, "innerSets");
    xdr::validate(obj);
  }
};
} namespace stellar {

}

#endif // !__XDR_XDR_STELLAR_SCP_H_INCLUDED__
