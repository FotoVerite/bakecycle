var React = require('react');

module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      errors: {},
      bakersPercentage: '',
      inclusionableIdType: '',
      availableInclusions: [],
      sortId: ''
    };
  },

  errorFor: function(field) {
    if (!this.props.errors[field]) { return; }
    return (<small className="error">{this.props.errors[field]}</small>);
  },

  errorClassFor: function(field) {
    if (!this.props.errors[field]) { return; }
    return 'error';
  },

  toggleDestroy: function() {
    this.props.store.toggleDestroy(this.props._id);
  },

  updateBakersPercentage: function(event) {
    this.props.store.updateField(this.props._id, 'bakersPercentage', event.target.value);
  },

  updateInclusionableIdType: function(event) {
    this.props.store.updateField(this.props._id, 'inclusionableIdType', event.target.value);
  },

  updateSortId: function(event) {
    this.props.store.updateField(this.props._id, 'sortId', event.target.value);
  },

  render: function() {
    var {
      index,
      id,
      _id,
      sortId,
      bakersPercentage,
      inclusionableIdType,
      availableInclusions,
      inclusionableType,
      totalLeadDays,
      dragEnd,
      dragStart,
      destroy
    } = this.props;
    var namePrefix = `recipe[recipe_items_attributes][${index}]`;
    var backgroundStyle = destroy ? { backgroundColor: 'lightgrey' } : {};
    var undoButton = <a onClick={this.toggleDestroy} className="button alert postfix" >Undo</a>;
    var removeButton = <a onClick={this.toggleDestroy} className="test-remove-button button alert postfix" >X</a>;
    var recipeOptions = availableInclusions.map((item) => {
      return <option value={item[1]}>{item[0]}</option>;
    });

    return (<div
        data-id={_id}
        draggable="true"
        onDragEnd={dragEnd}
        onDragStart={dragStart}
        className='fields' >
      <input type="hidden" name={`${namePrefix}[id]`} value={id} />
      <input type="hidden" name={`${namePrefix}[sort_id]`} value={sortId} />
      <input type="hidden" name={`${namePrefix}[_destroy]`} value={destroy} />
      <div className="row collapse">
        <div className="small-12 medium-4 columns">
          <i className='drag-handle fi-record inline'></i>
          <select
            value={inclusionableIdType}
            onChange={this.updateInclusionableIdType}
            className={`inclusionable_id_type inline ${this.errorClassFor('inclusionable_id_type')}`}
            name={`${namePrefix}[inclusionable_id_type]`}
            style={backgroundStyle}
            type="text"
          >
            {{recipeOptions}}
          </select>
          {this.errorFor('inclusionable_id_type')}
        </div>

        <div className="small-12 medium-2 columns">
          <input
            className={`bakers_percentage_input ${this.errorClassFor('bakersPercentage')}`}
            name={`${namePrefix}[bakers_percentage]`}
            onChange={this.updateBakersPercentage}
            placeholder="0"
            style={backgroundStyle}
            type="text"
            value={bakersPercentage} />
          {this.errorFor('bakersPercentage')}
        </div>

        <div className="small-12 medium-2 columns">
          <input
            className={`inclusionable_type_input`}
            disabled='true'
            name={`${namePrefix}[inclusionable_type]`}
            onChange={this.updateInclusionableType}
            style={backgroundStyle}
            type="text"
            value={inclusionableType} />
          {this.errorFor('inclusionable_type')}
        </div>

        <div className="small-12 medium-2 columns">
          <input
            className={`total_lead_days_input`}
            disabled='true'
            style={backgroundStyle}
            type="text"
            value={totalLeadDays} />
        </div>

        <div className="small-12 medium-2 columns">
          {destroy ? undoButton : removeButton}
        </div>
      </div>
    </div>);
  },
});
