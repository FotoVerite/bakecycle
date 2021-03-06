import React, { PropTypes } from 'react';
import { BCInput, BCSelect } from './bakecycle-inputs';

export default function RecipeItemFields({
  availableInclusions,
  dragEnd,
  dragStart,
  model,
}) {
  const data = model.toJSON();
  const {
    id,
    inclusionableTypeDisplay,
    sortId,
    destroy,
    totalLeadDays,
  } = data;

  const onChange = model.set.bind(model);

  const toggleDestroy = () => {
    var destroy = model.get('destroy');
    model.set({ destroy: !destroy });
  };

  var namePrefix = `recipe[recipe_items_attributes][${model.getNumericCID()}]`;
  var undoButton = <a onClick={toggleDestroy} className="button alert postfix" >Undo</a>;
  var removeButton = <a onClick={toggleDestroy} className="test-remove-button button alert postfix" >X</a>;
  var recipeOptions = availableInclusions.map((item) => {
    return <option key={`recipe-${id}-${item[1]}`} value={item[1]}>{item[0]}</option>;
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
        <i className="drag-handle fi-record inline"></i>
        <BCSelect
          value={data['inclusionableIdType']}
          field="inclusionableIdType"
          name={`${namePrefix}[inclusionable_id_type]`}
          options={recipeOptions}
          error={model.getError('inclusionable_id_type')}
          disabled={destroy}
          required
          inline
          onChange={onChange}
        />
      </div>
      <div className="small-12 medium-2 columns">
        <BCInput
          value={data['bakersPercentage']}
          field="bakersPercentage"
          name={`${namePrefix}[bakers_percentage]`}
          type="number"
          error={model.getError('bakers_percentage')}
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
}

RecipeItemFields.propTypes = {
  availableInclusions: PropTypes.array.isRequired,
  dragEnd: PropTypes.func.isRequired,
  dragStart: PropTypes.func.isRequired,
  model: PropTypes.object.isRequired
};
