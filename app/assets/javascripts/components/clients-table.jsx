import React from 'react';
import PropTypes from 'prop-types';
function filterClients(collection, filter) {
  function nameMatch(client) {
    const name = client.name.toLowerCase();
    const search = filter.name.toLowerCase();
    const searchChars = search.split('').filter(char => char !== ' ');
    let lastPostion = 0;
    return !searchChars.find(char => {
      lastPostion = name.indexOf(char, lastPostion) + 1;
      if (lastPostion === 0) { return true; }
    });
  }

  function activeMatch(client) {
    const activeSearch = filter.active;
    if (activeSearch === 'any') { return true; }
    return activeSearch === client.active + '';
  }

  function statusMatch(client) {
    return filter.engagementStatus === client.engagementStatus + '';
  }

  return collection.filter(c => nameMatch(c) && activeMatch(c) && statusMatch(c));
}

function capitalize(val) {
  return String(val).charAt(0).toUpperCase() + String(val).slice(1);
}

class ClientsTable extends React.Component {
  constructor(props) {
    super(props);
    const clients = props.data;
    const search = { active: 'true', name: '', engagementStatus: 'current' };
    this.state = { clients, search, filteredClients: filterClients(clients, search) };
    this.searchName = this.searchName.bind(this);
    this.searchActive = this.searchActive.bind(this);
    this.searchStatus = this.searchStatus.bind(this);
    this.chooseName = this.chooseName.bind(this);
  }

  setSearch(search) {
    this.setState({ filteredClients: filterClients(this.state.clients, search), search });
  }

  searchName(event) {
    this.setSearch({ name: event.target.value, active: this.state.search.active, engagementStatus: this.state.search.engagementStatus });
  }

  searchActive(event) {
    this.setSearch({ name: this.state.search.name, active: event.target.value, engagementStatus: this.state.search.engagementStatus });
  }

  searchStatus(event) {
    this.setSearch({ name: this.state.search.name, active: this.state.search.active, engagementStatus: event.target.value });
  }

  chooseName(e) {
    if (e.key !== 'Enter') { return; }
    const clients = this.state.filteredClients;
    if (clients.length === 1) { document.location.href = clients[0].links.view; }
  }

  search() {
    return (
      <div className="row collapse bakecycle-form">
        <div className="small-12 medium-4 columns">
          <div className="input string optional">
            <label className="string optional">Name</label>
            <input
              className="string optional"
              placeholder="Client Name"
              type="text"
              value={this.state.search.name}
              onChange={this.searchName}
              onKeyDown={this.chooseName}
            />
          </div>
        </div>
        <div className="small-12 medium-1 columns">
          <div className="input string optional">
            <label className="string optional">Status?</label>
            <select value={this.state.search.engagementStatus} onChange={this.searchStatus}>
              <option value="current">Current</option>
              <option value="lapsed">Lapsed</option>
              <option value="prospective">Prospective</option>
            </select>
          </div>
        </div>
        <div className="small-12 medium-1 columns">
          <div className="input string optional">
            <label className="string optional">Active?</label>
            <select value={this.state.search.active} onChange={this.searchActive}>
              <option value="true">Yes</option>
              <option value="false">No</option>
              <option value="any">Any</option>
            </select>
          </div>
        </div>
        <div className="small-12 medium-4 end columns">
          <div className="input string optional">
            <label className="string optional">&nbsp;</label>
            <a
              className="button small"
              target="_blank"
              style={{ marginLeft: 20, paddingTop: 10, paddingBottom: 10 }}
              href={`/clients/print_client_list?type=${this.state.search.active}`}>Export Client List</a>
          </div>
        </div>
      </div>
    );
  }

  header() {
    return (
      <thead>
        <tr>
          <th scope="col">Name</th>
          <th scope="col">Status</th>
          <th scope="col">Active</th>
          <th scope="col">Actions</th>
        </tr>
      </thead>
    );
  }

  rows() {
    return this.state.filteredClients.map(function(client) {
      return (
        <tr className="js-clickable-row" href={client.links.view} key={client.id}>
          <th scope="row"><a href={client.links.view}>{client.name}</a></th>
          <td data-title="Status">{capitalize(client.engagementStatus)}</td>
          <td data-title="Active">{client.active ? 'Yes' : 'No'}</td>
          <td data-title="Actions">
            <a href={client.links.edit}>
              <span className="table-action-icon icon-link-tooltip" aria-label="Edit Client">
                <i className="fi-page-edit"></i>
              </span>
            </a>
            <a href={client.links.view}>
              <span className="table-action-icon icon-link-tooltip" aria-label="View Client">
                <i className="fi-eye"></i>
              </span>
            </a>
            <a href={client.links.newOrder}>
              <span className="table-action-icon icon-link-tooltip" aria-label="Add Order For This Client">
                <i className="fi-page-add"></i>
              </span>
            </a>
          </td>
        </tr>
      );
    });
  }

  render() {
    return (
      <div>
        {this.search()}
        <table className="responsive-table clients-index">
          {this.header()}
          <tbody>{this.rows()}</tbody>
        </table>
      </div>
    );
  }
}

ClientsTable.propTypes = {
  data: PropTypes.object.isRequired,
};

export default ClientsTable;
