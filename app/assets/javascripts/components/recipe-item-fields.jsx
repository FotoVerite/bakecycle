import React from 'react';
import PropTypes from 'prop-types';

import { BCInput, BCSelect } from './bakecycle-inputs';

export default function RecipeItemFields({
  availableInclusions,
  dragEnd,
  dragStart,
  model,
  index,
  onChange,
  onToggleDestroy,
  getError,
}) {
  const {
    id,
    inclusionableTypeDisplay,
    destroy,
    totalLeadDays,
    inclusionableIdType,
    bakersPercentage,
  } = model;

  var namePrefix = `recipe[recipe_items_attributes][${model._key}]`;
  var undoButton = <a onClick={onToggleDestroy} className="button alert postfix" >Undo</a>;
  var removeButton = <a onClick={onToggleDestroy} className="test-remove-button button alert postfix" >X</a>;
  var recipeOptions = availableInclusions.map((item) => (
    <option key={`recipe-${id}-${item[1]}`} value={item[1]}>{item[0]}</option>
  ));

  var disabledClass = destroy ? 'disabled' : '';

  return (<div
    data-id={String(model._key)}
    draggable="true"
    onDragEnd={dragEnd}
    onDragStart={dragStart}
    className={`fields ${disabledClass}`} >
    <input type="hidden" name={`${namePrefix}[id]`} value={id} />
    <input type="hidden" name={`${namePrefix}[sort_id]`} value={index} />
    <input type="hidden" name={`${namePrefix}[_destroy]`} value={destroy} />
    <div className="row collapse">
      <div className="small-12 medium-4 columns">
        <i className="drag-handle fi-record inline"></i>
        <BCSelect
          value={inclusionableIdType}
          field="inclusionableIdType"
          name={`${namePrefix}[inclusionable_id_type]`}
          options={recipeOptions}
          error={getError('inclusionable_id_type')}
          disabled={destroy}
          required
          inline
          onChange={onChange}
        />
      </div>
      <div className="small-12 medium-2 columns">
        <BCInput
          value={bakersPercentage}
          field="bakersPercentage"
          name={`${namePrefix}[bakers_percentage]`}
          type="number"
          error={getError('bakers_percentage')}
          placeholder="0"
          disabled={destroy}
          required
          onChange={onChange}
        />
      </div>

      <div className="small-12 medium-2 columns">
        <input
          className="input text"
          type="text"
          disabled
          readOnly
          value={inclusionableTypeDisplay ?? ''} />
      </div>

      <div className="small-12 medium-2 columns">
        <input
          className="input text"
          type="text"
          disabled
          readOnly
          value={totalLeadDays ?? ''} />
      </div>

      <div className="small-12 medium-1 end columns">
        {destroy ? undoButton : removeButton}
      </div>
    </div>
  </div>);
}

RecipeItemFields.propTypes = {
  availableInclusions: PropTypes.array.isRequired,
  dragEnd: PropTypes.func.isRequired,
  dragStart: PropTypes.func.isRequired,
  model: PropTypes.object.isRequired,
  index: PropTypes.number.isRequired,
  onChange: PropTypes.func.isRequired,
  onToggleDestroy: PropTypes.func.isRequired,
  getError: PropTypes.func.isRequired,
};
