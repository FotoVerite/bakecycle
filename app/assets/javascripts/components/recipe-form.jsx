import React from 'react';
import PropTypes from 'prop-types';
import { BCInput, BCTextarea, BCSelect } from './bakecycle-inputs';
import RecipeItemsForm from './recipe-items-form';

function initItems(recipeItems) {
  let keyCounter = 0;
  const items = recipeItems.map(data => ({
    ...data,
    _key: keyCounter++,
    sortId: data.sortId !== undefined ? data.sortId : keyCounter - 1,
  }));
  // addBlankForm: add a blank entry if empty or if last item is persisted
  if (items.length === 0 || items[items.length - 1].id) {
    items.push({ _key: keyCounter++, sortId: items.length });
  }
  return { items, keyCounter };
}

class RecipeForm extends React.Component {
  constructor(props) {
    super(props);
    const { items, keyCounter } = initItems(props.recipeItems);
    this._keyCounter = keyCounter;
    this.state = { recipe: { ...props }, items };
    this.updateRecipe = this.updateRecipe.bind(this);
    this.addItem = this.addItem.bind(this);
    this.updateItem = this.updateItem.bind(this);
    this.toggleDestroyItem = this.toggleDestroyItem.bind(this);
    this.moveItem = this.moveItem.bind(this);
  }

  updateRecipe(data) {
    this.setState(state => ({ recipe: { ...state.recipe, ...data } }));
  }

  addItem() {
    const newItem = { _key: this._keyCounter++, sortId: this.state.items.length };
    this.setState(state => ({ items: [...state.items, newItem] }));
  }

  updateItem(item, data) {
    this.setState(state => ({
      items: state.items.map(i => i === item ? { ...i, ...data } : i),
    }));
  }

  toggleDestroyItem(item) {
    if (!item.id) {
      this.setState(state => ({ items: state.items.filter(i => i !== item) }));
    } else {
      this.updateItem(item, { destroy: !item.destroy });
    }
  }

  moveItem(draggedKey, targetKey, after) {
    this.setState(state => {
      const movedItem = state.items.find(i => String(i._key) === draggedKey);
      const filtered = state.items.filter(i => String(i._key) !== draggedKey);
      let targetIdx = filtered.findIndex(i => String(i._key) === targetKey);
      if (after) targetIdx += 1;
      const result = [...filtered];
      result.splice(targetIdx, 0, movedItem);
      return { items: result };
    });
  }

  errorFor(field) {
    if (!this.props.errors[field]) { return; }
    return (<small className="error">{this.props.errors[field]}</small>);
  }

  errorClassFor(field) {
    if (!this.props.errors[field]) { return; }
    return 'error';
  }

  showLeadDays() {
    const { recipe } = this.state;
    if (recipe.recipeType !== 'dough') { return; }
    return (
      <div className="row">
        <div className="small-4 columns end">
          <BCInput
            value={recipe.leadDays}
            field="leadDays"
            name="recipe[lead_days]"
            label="Lead Days"
            required
            error={this.props.errors.lead_days}
            onChange={this.updateRecipe}
          />
        </div>
      </div>
    );
  }

  mixUnitsOptions() {
    return (this.state.recipe.mixUnits || []).map((mixUnit) => (
      <option key={mixUnit[0]} value={mixUnit[0]}>{mixUnit[0]}</option>
    ));
  }

  recipeTypeOptions() {
    return (this.state.recipe.recipeTypes || []).map((recipeType) => (
      <option key={recipeType[0]} value={recipeType[0]}>{recipeType[0]}</option>
    ));
  }

  render() {
    const { recipe, items } = this.state;
    return (
      <div>
        <fieldset>
          <legend>Recipe Information</legend>
          <div className="row">
            <div className="small-12 columns">
              <BCInput value={recipe.name} field="name" name="recipe[name]" label="Name" required error={this.props.errors.name} onChange={this.updateRecipe} />
            </div>
          </div>
          <div className="row">
            <div className="small-12 columns">
              <BCTextarea value={recipe.note} field="note" name="recipe[note]" label="Note" error={this.props.errors.note} onChange={this.updateRecipe} />
            </div>
          </div>
          <div className="row">
            <div className="small-4 columns">
              <BCSelect value={recipe.recipeType} field="recipeType" options={this.recipeTypeOptions()} name="recipe[recipe_type]" label="Recipe type" required error={this.props.errors.recipe_type} onChange={this.updateRecipe} />
            </div>
            <div className="small-4 columns">
              <BCInput value={recipe.mixSize} field="mixSize" name="recipe[mix_size]" label="Mix Size" type="number" error={this.props.errors.mix_size} onChange={this.updateRecipe} />
              <p className="help-text">* Pre-ferment mix bowls will match motherdough bowls when only included in one motherdough</p>
            </div>
            <div className="small-4 columns">
              <BCSelect value={recipe.mixSizeUnit} field="mixSizeUnit" options={this.mixUnitsOptions()} name="recipe[mix_size_unit]" label="Mix Units" error={this.props.errors.mix_size_unit} onChange={this.updateRecipe} />
            </div>
          </div>
          {this.showLeadDays()}
        </fieldset>
        <RecipeItemsForm
          recipe={recipe}
          items={items}
          onAddItem={this.addItem}
          onUpdateItem={this.updateItem}
          onToggleDestroyItem={this.toggleDestroyItem}
          onMoveItem={this.moveItem}
        />
      </div>
    );
  }
}

RecipeForm.propTypes = {
  errors: PropTypes.object.isRequired,
  recipeItems: PropTypes.array.isRequired,
};

export default RecipeForm;
