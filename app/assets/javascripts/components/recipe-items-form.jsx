import React from 'react';
import PropTypes from 'prop-types';

import RecipeItemFields from './recipe-item-fields';

function getError(item, field) {
  const errors = item.errors || {};
  const val = errors[field];
  return Array.isArray(val) ? val[0] : val;
}

class RecipeItemsForm extends React.Component {
  constructor(props) {
    super(props);
    this.placeholder = document.createElement('div');
    this.placeholder.className = 'draggable-placeholder';
    this.addItem = this.addItem.bind(this);
    this.dragStart = this.dragStart.bind(this);
    this.dragEnd = this.dragEnd.bind(this);
    this.dragOver = this.dragOver.bind(this);
  }

  addItem(event) {
    event.preventDefault();
    this.props.onAddItem();
  }

  availableInclusions() {
    const { recipe } = this.props;
    if (recipe.recipeType === 'dough') {
      return recipe.availableInclusions || [];
    } else {
      return recipe.availableRecipeIngredients || [];
    }
  }

  dragStart(e) {
    this.dragged = e.target;
    this.draggedOver = false;
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/html', this.dragged);
  }

  dragEnd() {
    this.dragged.style.display = 'block';
    this.placeholder.remove();
    if (!this.draggedOver) { return; }
    const draggedKey = this.dragged.dataset.id;
    const targetKey = this.draggedOver.dataset.id;
    this.props.onMoveItem(draggedKey, targetKey, this.draggedPosition === 'after');
  }

  dragOver(e) {
    e.preventDefault();
    var over = $(e.target).closest('[draggable=true]').get(0);
    if (!over) { return; }
    this.draggedOver = over;
    this.dragged.style.display = 'none';

    var overBoundingBox = this.draggedOver.getBoundingClientRect();
    var middle = overBoundingBox.height / 2;
    var relativeToMiddle = e.clientY - overBoundingBox.top - middle;
    var parent = this.draggedOver.parentNode;
    if (relativeToMiddle > 0) {
      this.draggedPosition = 'after';
      parent.insertBefore(this.placeholder, this.draggedOver.nextElementSibling);
    } else {
      this.draggedPosition = 'before';
      parent.insertBefore(this.placeholder, this.draggedOver);
    }
  }

  render() {
    const { items, onUpdateItem, onToggleDestroyItem } = this.props;
    const availableInclusions = this.availableInclusions();
    const fields = items.map((item, index) => (
      <RecipeItemFields
        key={item._key}
        availableInclusions={availableInclusions}
        model={item}
        index={index}
        dragStart={this.dragStart}
        dragEnd={this.dragEnd}
        onChange={(data) => onUpdateItem(item, data)}
        onToggleDestroy={() => onToggleDestroyItem(item)}
        getError={(field) => getError(item, field)}
      />
    ));

    return (<div onDragOver={this.dragOver}>
      <fieldset>
        <legend>Ingredients</legend>
        <div className="row collapse">
          <div className="small-12 medium-4 columns">
            <label className="show-for-medium-up">Ingredient</label>
          </div>
          <div className="small-12 medium-2 columns">
            <label className="show-for-medium-up">Baker&#39;s %</label>
          </div>
          <div className="small-12 medium-2 columns">
            <label className="show-for-medium-up">Type</label>
          </div>
          <div className="small-12 medium-2 columns end">
            <label className="show-for-medium-up">Lead time</label>
          </div>
        </div>
        {fields}
        <a href="#" onClick={this.addItem} className="button">Add New Ingredient</a>
      </fieldset>
    </div>);
  }
}

RecipeItemsForm.propTypes = {
  recipe: PropTypes.object.isRequired,
  items: PropTypes.array.isRequired,
  onAddItem: PropTypes.func.isRequired,
  onUpdateItem: PropTypes.func.isRequired,
  onToggleDestroyItem: PropTypes.func.isRequired,
  onMoveItem: PropTypes.func.isRequired,
};

export default RecipeItemsForm;
