import React from 'react';
import { BCInput, BCSelect } from './bakecycle-backbone-inputs';

module.exports = React.createClass({
  toggleDestroy: function() {
    var model = this.props.model;
    var destroy = model.get('destroy');
    model.set({ destroy: !destroy });
  },

  render: function() {
    var {
      availableInclusions,
      dragEnd,
      dragStart,
      model,
    } = this.props;
    var {
      id,
      inclusionableTypeDisplay,
      sortId,
      destroy,
      totalLeadDays,
    } = model.toJSON();
    var namePrefix = `recipe[recipe_items_attributes][${model.getNumericCID()}]`;
    var undoButton = <a onClick={this.toggleDestroy} className="button alert postfix" >Undo</a>;
    var removeButton = <a onClick={this.toggleDestroy} className="test-remove-button button alert postfix" >X</a>;
    var recipeOptions = availableInclusions.map((item) => {
      return <option value={item[1]}>{item[0]}</option>;
    });

    var disabledClass = destroy ? 'disabled' : '';

    return (<div
        data-id={model.cid}
        draggable="true"
        onDragEnd={dragEnd}
        onDragStart={dragStart}
        className={`fields ${disabledClass}`} >
      <input type="hidden" name={`${namePrefix}[id]`} value={id} />
      <input type="hidden" name={`${namePrefix}[sort_id]`} value={sortId} />
      <input type="hidden" name={`${namePrefix}[_destroy]`} value={destroy} />
      <div className="row collapse">
        <div className="small-12 medium-4 columns">
          <i className='drag-handle fi-record inline'></i>
          <BCSelect
            model={model}
            field="inclusionableIdType"
            name={`${namePrefix}[inclusionable_id_type]`}
            options={recipeOptions}
            error={model.getError('inclusionable_id_type')}
            disabled={destroy}
            required
            inline
          />
        </div>
        <div className="small-12 medium-2 columns">
          <BCInput
            model={model}
            field="bakersPercentage"
            name={`${namePrefix}[bakers_percentage]`}
            type="number"
            error={model.getError('bakers_percentage')}
            placeholder="0"
            disabled={destroy}
            required
          />
        </div>

        <div className="small-12 medium-2 columns">
          <input
            className="input text"
            type="text"
            disabled
            value={inclusionableTypeDisplay} />
        </div>

        <div className="small-12 medium-2 columns">
          <input
            className="input text"
            type="text"
            disabled
            value={totalLeadDays} />
        </div>

        <div className="small-12 medium-1 end columns">
          {destroy ? undoButton : removeButton}
        </div>
      </div>
    </div>);
  },
});
